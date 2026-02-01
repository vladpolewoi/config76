#!/bin/bash

# Check if file-roller is installed
if ! command -v file-roller &>/dev/null; then
  echo "📦 'file-roller' not found. Installing..."
  sudo pacman -S --needed --noconfirm file-roller
  echo "✅ 'file-roller' installed."
else
  echo "✅ 'file-roller' is already installed."
fi
