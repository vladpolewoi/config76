#!/bin/bash

echo "=-=-=-=- Reloading Configs -=-=-=-="

./env.sh

# Reload Hyprland config
hyprctl reload

# Restart Waybar
pkill waybar
setsid waybar >/dev/null 2>&1 < /dev/null &

# Restart Swaync
pkill swaync
swaync >/dev/null 2>&1 < /dev/null &

# Restart Slideshow
pkill -f slideshow.sh
setsid "$HOME/config76/arch/scripts/slideshow.sh" >/dev/null 2>&1 < /dev/null &


