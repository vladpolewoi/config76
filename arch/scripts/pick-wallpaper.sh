#!/bin/bash

WALLPAPER_DIR="$HOME/config76/arch/wallpaper"
MONITOR=""

# Ensure hyprpaper is running
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
  WALL_PATH="${WALL_MAP[$CHOSEN]}"

  # Preload the chosen wallpaper
  hyprctl hyprpaper preload "$WALL_PATH"

  # Set as wallpaper
  hyprctl hyprpaper wallpaper "$MONITOR,$WALL_PATH"
fi

