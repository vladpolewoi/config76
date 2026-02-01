#!/bin/bash

# Check if gparted is installed
if ! command -v gparted &>/dev/null; then
  echo "📦 'gparted' not found. Installing..."
  sudo pacman -S --needed --noconfirm gparted
  echo "✅ 'gparted' installed."
else
  echo "✅ 'gparted' is already installed."
fi
