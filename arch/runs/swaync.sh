#!/bin/bash

set -e

echo "📦 Installing swaync (SwayNotificationCenter)..."
sudo pacman -S --noconfirm swaync libnotify

echo "✅ swaync is installed and configured!"

