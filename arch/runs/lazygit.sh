#!/bin/bash

# Check if lazygit is installed
if ! command -v lazygit &>/dev/null; then
  echo "📦 'lazygit' not found. Installing..."
  sudo pacman -S --needed --noconfirm lazygit
  echo "✅ 'lazygit' installed."
else
  echo "✅ 'lazygit' is already installed."
fi
