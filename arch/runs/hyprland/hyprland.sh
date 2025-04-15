#!/bin/bash

set -e

echo "=-=-=-=- Installing Hyprland -=-=-=-="

# Install packages
sudo pacman -S --noconfirm hyprland xorg-server-xwayland wl-clipboard

echo "=-=-=-=- Done -=-=-=-="

