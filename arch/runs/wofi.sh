#!/bin/bash

# Check if wofi is installed
if ! command -v wofi &>/dev/null; then
  echo "📦 'wofi' not found. Installing..."

  # Use yay if available, else fall back to pacman
  if command -v yay &>/dev/null; then
    yay -S --noconfirm wofi
  else
    sudo pacman -S --needed --noconfirm wofi
  fi

  echo "✅ 'wofi' installed."
else
  echo "✅ 'wofi' is already installed."
fi

