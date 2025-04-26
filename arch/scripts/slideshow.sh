#!/bin/bash

WALLPAPER_DIR="$HOME/config76/arch/wallpaper"
INTERVAL=600 # 10m  
MONITOR=""

# Get list of wallpapers (sorted for consistency)
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort)

COUNT=${#WALLPAPERS[@]}
INDEX=0

while true; do
  WALL="${WALLPAPERS[$INDEX]}"

  if [[ -f "$WALL" ]]; then
    hyprctl hyprpaper preload "$WALL"
    hyprctl hyprpaper wallpaper "$MONITOR,$WALL"
  fi

  # Move to next wallpaper
  ((INDEX = (INDEX + 1) % COUNT))

  sleep "$INTERVAL"
done

