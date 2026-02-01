#!/bin/bash

# Check if mpv is installed
if ! command -v mpv &>/dev/null; then
  echo "📦 'mpv' not found. Installing..."
  sudo pacman -S --needed --noconfirm mpv
  echo "✅ 'mpv' installed."
else
  echo "✅ 'mpv' is already installed."
fi
