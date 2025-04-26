#!/bin/bash

set -e

echo "🔒 Installing Hyprlock..."

# Install Hyprlock only
sudo pacman -S --needed hyprlock


echo "✅ Done! You can test Hyprlock now with: hyprlock"

