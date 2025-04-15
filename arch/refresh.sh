#!/bin/bash

echo "=-=-=-=- Reloading Configs -=-=-=-="

./env.sh

# Reload Hyprland config
hyprctl reload

# Restart Waybar
pkill -9 waybar && waybar &






