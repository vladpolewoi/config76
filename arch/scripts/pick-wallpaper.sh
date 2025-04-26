#!/bin/bash

WALLPAPER_DIR="$HOME/config76/arch/wallpaper"
MONITOR=""

# Ensure hyprpaper is running (optional)
pgrep -x hyprpaper &>/dev/null || hyprpaper &

# Build a map of name → full path
declare -A WALL_MAP
while IFS= read -r path; do
  name=$(basename "$path")
  WALL_MAP["$name"]="$path"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \))

# Show only file names
CHOSEN=$(printf "%s\n" "${!WALL_MAP[@]}" | sort | wofi --dmenu --prompt "Choose wallpaper")

# Apply selected wallpaper
if [[ -n "$CHOSEN" && -f "${WALL_MAP[$CHOSEN]}" ]]; then
  hyprctl hyprpaper reload , "${WALL_MAP[$CHOSEN]}"
  # hyprctl hyprpaper preload "${WALL_MAP[$CHOSEN]}"
  # hyprctl hyprpaper wallpaper "$MONITOR,${WALL_MAP[$CHOSEN]}"
fi

