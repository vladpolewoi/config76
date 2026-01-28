#!/bin/bash

WALLPAPER_DIR="$HOME/config76/arch/wallpaper"
INTERVAL=600 # 10m
MONITOR=""

# Wait for hyprpaper to be ready
sleep 2

# Get list of wallpapers (sorted for consistency)
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort)

COUNT=${#WALLPAPERS[@]}
INDEX=0
PREV_WALL=""

while true; do
  WALL="${WALLPAPERS[$INDEX]}"

  if [[ -f "$WALL" ]]; then
    # Preload new wallpaper
    hyprctl hyprpaper preload "$WALL"

    # Set new wallpaper
    hyprctl hyprpaper wallpaper "$MONITOR,$WALL"

    # Unload previous wallpaper to save memory
    if [[ -n "$PREV_WALL" && "$PREV_WALL" != "$WALL" ]]; then
      hyprctl hyprpaper unload "$PREV_WALL"
    fi

    PREV_WALL="$WALL"
  fi

  # Move to next wallpaper
  ((INDEX = (INDEX + 1) % COUNT))

  sleep "$INTERVAL"
done

