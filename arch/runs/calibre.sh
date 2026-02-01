#!/bin/bash

# Check if calibre is installed
if ! command -v calibre &>/dev/null; then
  echo "📦 'calibre' not found. Installing..."
  sudo pacman -S --needed --noconfirm calibre
  echo "✅ 'calibre' installed."
else
  echo "✅ 'calibre' is already installed."
fi
