#!/usr/bin/env bash
# Waybar custom module: Claude Code usage (5-hour rolling window).
# Source: Anthropic OAuth usage endpoint (same data as the in-app /usage view).
# Emits Waybar JSON: {text, class, tooltip, percentage}.
#
# Animation states are driven by /tmp/claude-usage.state (written by the
# on-click refresh script):
#   spin:<glyph>   pulsing cyan spinner frame   (class refreshing)
#   done           green "✓ updated" confirmation (class done)
#   (absent)       normal render, fetched live   (class ok|warn|crit|error)

CREDS="$HOME/.claude/.credentials.json"
ENDPOINT="https://api.anthropic.com/api/oauth/usage"
CACHE="/tmp/claude-usage.json"
STATE="/tmp/claude-usage.state"
ROBOT="󰚩"   # nf-md-robot

emit() { # text  class  tooltip  percentage
  jq -cn --arg t "$1" --arg c "$2" --arg tt "$3" --argjson p "${4:-0}" \
    '{text:$t, class:$c, tooltip:$tt, percentage:$p}'
}

# ISO-8601 → "Xh Ym" until reset
human_eta() {
  local epoch now diff h m
  epoch=$(date -d "$1" +%s 2>/dev/null) || { echo "?"; return; }
  now=$(date +%s); diff=$(( epoch - now ))
  [ "$diff" -lt 0 ] && diff=0
  h=$(( diff / 3600 )); m=$(( (diff % 3600) / 60 ))
  if [ "$h" -gt 0 ]; then echo "${h}h ${m}m"; else echo "${m}m"; fi
}

# Render the cached usage with a given text-prefix and class override.
render_from_cache() { # prefix  class("" = auto severity)
  local prefix="$1" cls="$2" resp pct reset5 wpct reset7 eta5 eta7 tt
  resp=$(cat "$CACHE" 2>/dev/null)
  if ! echo "$resp" | jq -e '.five_hour.utilization' >/dev/null 2>&1; then
    emit "${ROBOT}  !" "error" "Claude: usage endpoint unavailable" 0; return
  fi
  pct=$(echo "$resp"   | jq -r '.five_hour.utilization | floor')
  reset5=$(echo "$resp"| jq -r '.five_hour.resets_at')
  wpct=$(echo "$resp"  | jq -r '.seven_day.utilization | floor')
  reset7=$(echo "$resp"| jq -r '.seven_day.resets_at')
  eta5=$(human_eta "$reset5"); eta7=$(human_eta "$reset7")
  if [ -z "$cls" ]; then
    if   [ "$pct" -ge 90 ]; then cls="crit"
    elif [ "$pct" -ge 70 ]; then cls="warn"
    else                         cls="ok"; fi
  fi
  tt=$(printf 'Claude Code usage\n\n5h window:  %s%%  · resets in %s\n7d window:  %s%%  · resets in %s\n\nclick to refresh' \
    "$pct" "$eta5" "$wpct" "$eta7")
  emit "${prefix}${pct}% · ${eta5}" "$cls" "$tt" "$pct"
}

# ── Animation states (set by the on-click refresh script) ───────────────────
state=$(cat "$STATE" 2>/dev/null)
case "$state" in
  spin:*) emit "${ROBOT}  ${state#spin:}" "refreshing" "Refreshing Claude usage…" 0; exit 0 ;;
  done)   render_from_cache "${ROBOT}  󰄬 " "done"; exit 0 ;;
esac

# ── Normal render: fetch live, fall back to cache, then render ──────────────
TOKEN=$(jq -r '.claudeAiOauth.accessToken // empty' "$CREDS" 2>/dev/null)
if [ -z "$TOKEN" ]; then
  emit "${ROBOT}  ?" "error" "Claude: no credentials in $CREDS" 0; exit 0
fi
resp=$(curl -s --max-time 4 \
  -H "Authorization: Bearer $TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" \
  "$ENDPOINT" 2>/dev/null)
if echo "$resp" | jq -e '.five_hour.utilization' >/dev/null 2>&1; then
  printf '%s' "$resp" > "$CACHE"
fi
render_from_cache "${ROBOT}  " ""
