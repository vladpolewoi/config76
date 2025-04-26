#!/bin/bash

# Check if telegram is installed
if ! command -v telegram &>/dev/null; then
  echo "📦 'telegram-desktop' not found. Installing..."

  # Use yay if available, else fall back to pacman
  if command -v yay &>/dev/null; then
    yay -S --noconfirm telegram-desktop
  else
    sudo pacman -S --needed --noconfirm telegram-desktop
  fi

  echo "✅ 'telegram-desktop' installed."
else
  echo "✅ 'telegram-desktop' is already installed."
fi
