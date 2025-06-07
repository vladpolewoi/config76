#!/bin/bash

# Check if rofi is installed
if ! command -v rofi &>/dev/null; then
  echo "📦 'rofi' not found. Installing..."

  if command -v yay &>/dev/null; then
    yay -S --noconfirm rofi
  else
    sudo pacman -S --needed --noconfirm rofi
  fi

  echo "✅ 'rofi' installed."
else
  echo "✅ 'rofi' is already installed."
fi
