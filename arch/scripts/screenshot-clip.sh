#!/bin/bash
# Region screenshot straight to clipboard, no editor window.
geom=$(slurp) || exit 0          # ESC / cancel -> do nothing, no notify
grim -g "$geom" - | wl-copy
notify-send -t 1500 "Screenshot copied"
