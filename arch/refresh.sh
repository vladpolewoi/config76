#!/bin/bash

script_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

echo "=-=-=-=- Reloading Configs -=-=-=-="

"$script_dir/env.sh"
"$script_dir/runs/hosts.sh"

# Set dark theme via gsettings (needed for freedesktop portal / app auto-theme detection)
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 10'
gsettings set org.gnome.desktop.interface document-font-name 'JetBrainsMono Nerd Font 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10'

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


