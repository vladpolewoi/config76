#!/bin/bash
# Waybar module: Cloudflare WARP status. Click toggles via warp-toggle.sh.

ICON=$''  # nf-fa-shield

if ! systemctl is-active --quiet warp-svc; then
  printf '{"text":"%s WARP","tooltip":"warp-svc not running","class":"error"}\n' "$ICON"
  exit 0
fi

status=$(warp-cli --accept-tos status 2>/dev/null | head -1)

case "$status" in
  *Connected*)
    printf '{"text":"%s WARP","tooltip":"WARP connected · click to disconnect","class":"connected"}\n' "$ICON"
    ;;
  *Connecting*)
    printf '{"text":"%s WARP","tooltip":"WARP connecting…","class":"connecting"}\n' "$ICON"
    ;;
  *)
    printf '{"text":"%s WARP","tooltip":"WARP off · click to connect","class":"off"}\n' "$ICON"
    ;;
esac
