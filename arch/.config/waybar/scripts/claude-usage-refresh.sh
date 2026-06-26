#!/usr/bin/env bash
# On-click handler for the custom/claude Waybar module.
# Visible 3-phase update so a click is obviously felt:
#   1. ~1s animated braille spinner (cyan, pulsing)   "it's working"
#   2. real fetch of fresh usage into the cache
#   3. ~0.9s green "✓ updated" flash                  "it's done"
#   4. settle back to the normal reading
# SIGNAL must match "signal" in the custom/claude module config.

SIGNAL=9
STATE="/tmp/claude-usage.state"
CACHE="/tmp/claude-usage.json"
CREDS="$HOME/.claude/.credentials.json"
ENDPOINT="https://api.anthropic.com/api/oauth/usage"

sig() { pkill -RTMIN+$SIGNAL waybar 2>/dev/null; }

frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

# Phase 1 — spinner motion (each frame is a re-exec of the module)
for i in $(seq 0 8); do
  printf 'spin:%s' "${frames[$(( i % ${#frames[@]} ))]}" > "$STATE"
  sig
  sleep 0.11
done

# Phase 2 — actually refresh the cached usage
TOKEN=$(jq -r '.claudeAiOauth.accessToken // empty' "$CREDS" 2>/dev/null)
if [ -n "$TOKEN" ]; then
  resp=$(curl -s --max-time 5 \
    -H "Authorization: Bearer $TOKEN" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "$ENDPOINT" 2>/dev/null)
  if echo "$resp" | jq -e '.five_hour.utilization' >/dev/null 2>&1; then
    printf '%s' "$resp" > "$CACHE"
  fi
fi

# Phase 3 — confirm
printf 'done' > "$STATE"; sig
sleep 0.9

# Phase 4 — settle
rm -f "$STATE"; sig
