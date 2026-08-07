#!/bin/bash
# Toggle Cloudflare WARP, then refresh the waybar module instantly.

if warp-cli --accept-tos status 2>/dev/null | head -1 | grep -q Connected; then
  warp-cli --accept-tos disconnect
else
  warp-cli --accept-tos connect
fi

pkill -RTMIN+10 waybar
