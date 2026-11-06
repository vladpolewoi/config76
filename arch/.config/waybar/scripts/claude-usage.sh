#!/usr/bin/env bash
# Waybar custom module: Claude Code plan usage.
# Source: Anthropic OAuth usage endpoint (same data as the in-app /usage view).
# Emits Waybar JSON: {text, class, tooltip, percentage}.
#
# Bar shows the session (5h) limit when the plan has one, else the weekly
# limit; the tooltip lists every limit. Reads the structured `limits[]` array,
# falling back to the legacy five_hour/seven_day fields. Plans without a 5h
# window return `five_hour: null` — parsing only that field froze the bar on a
# stale cache, so never key validity on a single window.
#
#   claude-usage.sh          render (fetch live, fall back to cache)
#   claude-usage.sh --fetch  refresh the cache only (on-click script uses it)
#
# Animation states are driven by /tmp/claude-usage.state (written by the
# on-click refresh script):
#   spin:<glyph>   pulsing cyan spinner frame   (class refreshing)
#   done           green "✓ updated" confirmation (class done)
#   (absent)       normal render, fetched live   (class ok|warn|crit|error [+stale])

CREDS="$HOME/.claude/.credentials.json"
ENDPOINT="https://api.anthropic.com/api/oauth/usage"
CACHE="/tmp/claude-usage.json"
STATE="/tmp/claude-usage.state"
STALE_AFTER=1800   # seconds; an older cache renders dimmed (class stale)
ROBOT="󰚩"   # nf-md-robot

# Response → [{kind, label, pct, resets_at}]
LIMITS_JQ='
  if (.limits | type) == "array" and (.limits | length) > 0 then
    [.limits[] | {
      kind,
      label: (if   .kind == "session"       then "session"
              elif .kind == "weekly_all"    then "weekly"
              elif .kind == "weekly_scoped" then "weekly · \(.scope.model.display_name // "scoped")"
              else .kind end),
      pct: ((.percent // 0) | floor),
      resets_at
    }]
  else
    [ (.five_hour | select(. != null)
        | {kind: "session",    label: "session", pct: ((.utilization // 0) | floor), resets_at}),
      (.seven_day | select(. != null)
        | {kind: "weekly_all", label: "weekly",  pct: ((.utilization // 0) | floor), resets_at}) ]
  end'

emit() { # text  classes(space-separated)  tooltip  percentage
  jq -cn --arg t "$1" --arg c "$2" --arg tt "$3" --argjson p "${4:-0}" \
    '{text:$t, class:($c | split(" ")), tooltip:$tt, percentage:$p}'
}

# ISO-8601 → "Xd Yh" / "Xh Ym" / "Xm" until reset
human_eta() {
  local epoch now diff d h m
  [ -n "$1" ] || return
  epoch=$(date -d "$1" +%s 2>/dev/null) || { echo "?"; return; }
  now=$(date +%s); diff=$(( epoch - now ))
  [ "$diff" -lt 0 ] && diff=0
  d=$(( diff / 86400 )); h=$(( (diff % 86400) / 3600 )); m=$(( (diff % 3600) / 60 ))
  if   [ "$d" -gt 0 ]; then echo "${d}d ${h}h"
  elif [ "$h" -gt 0 ]; then echo "${h}h ${m}m"
  else                      echo "${m}m"; fi
}

# Fetch live usage into the cache. 0 = cached, 1 = endpoint failed, 2 = no creds.
fetch() {
  local token resp
  token=$(jq -r '.claudeAiOauth.accessToken // empty' "$CREDS" 2>/dev/null)
  [ -n "$token" ] || return 2
  resp=$(curl -s --max-time 5 \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "$ENDPOINT" 2>/dev/null)
  printf '%s' "$resp" | jq -e "($LIMITS_JQ) | length > 0" >/dev/null 2>&1 || return 1
  printf '%s' "$resp" > "$CACHE.tmp" && mv -f "$CACHE.tmp" "$CACHE"
}

# Render the cached usage with a given text-prefix and class override.
render_from_cache() { # prefix  class("" = auto severity)
  local prefix="$1" cls="$2" limits primary pct eta worst age tt label lpct reset leta
  limits=$(jq -c "$LIMITS_JQ" "$CACHE" 2>/dev/null)
  if [ -z "$limits" ] || [ "$(jq 'length' <<<"$limits")" -eq 0 ]; then
    emit "${ROBOT}  !" "error" "Claude: usage endpoint unavailable" 0; return
  fi

  primary=$(jq -c 'first(.[] | select(.kind == "session"))
                // first(.[] | select(.kind == "weekly_all"))
                // max_by(.pct)' <<<"$limits")
  pct=$(jq -r '.pct' <<<"$primary")
  eta=$(human_eta "$(jq -r '.resets_at // empty' <<<"$primary")")

  if [ -z "$cls" ]; then
    # Colour by the tightest plan-wide limit, not just the one on the bar.
    worst=$(jq '[.[] | select(.kind == "session" or .kind == "weekly_all") | .pct] | max // 0' <<<"$limits")
    if   [ "$worst" -ge 90 ]; then cls="crit"
    elif [ "$worst" -ge 70 ]; then cls="warn"
    else                           cls="ok"; fi
  fi

  tt="Claude Code usage"$'\n'
  while IFS=$'\t' read -r label lpct reset; do
    leta=$(human_eta "$reset")
    tt+=$'\n'"${label}:  ${lpct}%${leta:+  · resets in $leta}"
  done < <(jq -r '.[] | [.label, .pct, (.resets_at // "")] | @tsv' <<<"$limits")

  age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
  if [ "$age" -gt "$STALE_AFTER" ]; then
    cls+=" stale"
    tt+=$'\n\n'"stale — last fetched $(date -d "@$(stat -c %Y "$CACHE")" +%H:%M)"
  fi
  tt+=$'\n\nclick to refresh'

  emit "${prefix}${pct}%${eta:+ · $eta}" "$cls" "$tt" "$pct"
}

[ "$1" = "--fetch" ] && { fetch; exit; }

# ── Animation states (set by the on-click refresh script) ───────────────────
state=$(cat "$STATE" 2>/dev/null)
case "$state" in
  spin:*) emit "${ROBOT}  ${state#spin:}" "refreshing" "Refreshing Claude usage…" 0; exit 0 ;;
  done)   render_from_cache "${ROBOT}  󰄬 " "done"; exit 0 ;;
esac

# ── Normal render: fetch live, fall back to cache, then render ──────────────
fetch
if [ $? -eq 2 ]; then
  emit "${ROBOT}  ?" "error" "Claude: no credentials in $CREDS" 0; exit 0
fi
render_from_cache "${ROBOT}  " ""
