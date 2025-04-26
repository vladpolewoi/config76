#!/bin/bash

set -e

echo "📦 Installing hyprpaper..."

# Install hyprpaper (official package)
sudo pacman -S --noconfirm --needed hyprpaper

echo "🛠️ Setting up config directory..."

