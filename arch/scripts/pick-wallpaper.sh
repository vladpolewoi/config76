#!/bin/bash

WALLPAPER_DIR="$HOME/config76/arch/wallpaper"
THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-thumbs"
WOFI_DIR="$HOME/.config/wofi"
MONITOR=""

mkdir -p "$THUMB_DIR"

# Ensure hyprpaper is running
pgrep -x hyprpaper &>/dev/null || hyprpaper &

# Build a map of thumbnail → full path. Thumbs are cropped to a uniform
# 16:9 so the grid looks even, and only regenerated when the source image
# is newer than the cached thumb.
declare -A WALL_MAP
ENTRIES=""
while IFS= read -r path; do
  name=$(basename "$path")
  thumb="$THUMB_DIR/${name%.*}.jpg"

  if [[ ! -f "$thumb" || "$path" -nt "$thumb" ]]; then
    ffmpeg -loglevel error -y -i "$path" \
      -vf "scale=400:225:force_original_aspect_ratio=increase,crop=400:225" \
      -frames:v 1 "$thumb"
  fi

  WALL_MAP["$thumb"]="$path"
  ENTRIES+="img:$thumb\n"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort -V)

# --cache-file /dev/null keeps wofi from reordering the grid by usage
CHOSEN=$(echo -en "$ENTRIES" | wofi --dmenu \
  --conf "$WOFI_DIR/wallpaper-picker" \
  --style "$WOFI_DIR/wallpaper-picker.css" \
  --cache-file /dev/null \
  --prompt "Wallpaper")

# Depending on wofi version the selection comes back as the plain thumb
# path or the full "img:..." line — strip down to the path.
CHOSEN="${CHOSEN#img:}"

# Apply selected wallpaper
if [[ -n "$CHOSEN" && -f "${WALL_MAP[$CHOSEN]}" ]]; then
  WALL_PATH="${WALL_MAP[$CHOSEN]}"

  hyprctl hyprpaper preload "$WALL_PATH"
  hyprctl hyprpaper wallpaper "$MONITOR,$WALL_PATH"
  hyprctl hyprpaper unload unused

  # Persist the choice so it survives a restart
  printf 'preload = %s\nwallpaper = %s,%s\n' \
    "$WALL_PATH" "$MONITOR" "$WALL_PATH" > "$HOME/.config/hypr/hyprpaper.conf"
fi
