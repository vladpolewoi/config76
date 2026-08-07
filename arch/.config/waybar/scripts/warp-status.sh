#!/bin/bash
# Waybar module: Cloudflare WARP status. Click toggles via warp-toggle.sh.
# Connected text shows colo + latency from `warp-cli tunnel stats` (local IPC).
# Public IP comes from a cdn-cgi/trace cache refreshed asynchronously so the
# module exec never blocks the bar.

ICON=$''  # nf-fa-shield
CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-warp-trace"

if ! systemctl is-active --quiet warp-svc; then
  printf '{"text":"%s WARP","tooltip":"warp-svc not running","class":"error"}\n' "$ICON"
  exit 0
fi

status=$(warp-cli --accept-tos status 2>/dev/null | head -1)

case "$status" in
  *Connected*)
    stats=$(warp-cli --accept-tos tunnel stats 2>/dev/null)
    proto=$(sed -n 's/^Tunnel Protocol: //p' <<<"$stats")
    colo=$(sed -n 's/^Colo: \([A-Z]*\).*/\1/p' <<<"$stats")
    lat=$(sed -n 's/^Estimated latency: //p' <<<"$stats")
    loss=$(sed -n 's/^Estimated loss: //p' <<<"$stats")
    traffic=$(sed -n 's/^Sent: \(.*\); Received: \(.*\)/↑\1 ↓\2/p' <<<"$stats")

    # Refresh public-IP cache in the background at most every 10 min.
    if [[ ! -f "$CACHE" || $(( $(date +%s) - $(stat -c %Y "$CACHE") )) -gt 600 ]]; then
      touch "$CACHE"
      (curl -s --max-time 3 https://www.cloudflare.com/cdn-cgi/trace > "$CACHE.tmp" \
        && mv "$CACHE.tmp" "$CACHE") &>/dev/null &
    fi
    ip=$(sed -n 's/^ip=//p' "$CACHE" 2>/dev/null)
    loc=$(sed -n 's/^loc=//p' "$CACHE" 2>/dev/null)

    class="connected"
    lat_ms=${lat%ms}; loss_pct=${loss%\%}
    [[ ${lat_ms%.*} -gt 150 || ${loss_pct%.*} -ge 5 ]] 2>/dev/null && class="warn"

    text="$ICON WARP ${colo:+$colo }$lat"
    tooltip="WARP connected — $proto\nColo $colo · latency $lat · loss $loss"
    [[ -n "$ip" ]] && tooltip+="\nIP $ip${loc:+ ($loc)}"
    [[ -n "$traffic" ]] && tooltip+="\n$traffic"
    tooltip+="\nclick: disconnect"
    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
    ;;
  *Connecting*)
    printf '{"text":"%s WARP …","tooltip":"WARP connecting…","class":"connecting"}\n' "$ICON"
    ;;
  *Registration*)
    printf '{"text":"%s WARP","tooltip":"no registration — run: warp-cli registration new","class":"error"}\n' "$ICON"
    ;;
  *)
    reason=$(warp-cli --accept-tos status 2>/dev/null | sed -n 's/^Reason: //p')
    printf '{"text":"%s WARP","tooltip":"WARP off%s · click to connect","class":"off"}\n' \
      "$ICON" "${reason:+ ($reason)}"
    ;;
esac
