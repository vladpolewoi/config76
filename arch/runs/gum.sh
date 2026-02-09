#!/bin/bash

# Check if gum is installed
if ! command -v gum &>/dev/null; then
  echo "📦 'gum' not found. Installing..."
  sudo pacman -S --needed --noconfirm gum
  echo "✅ 'gum' installed."
else
  echo "✅ 'gum' is already installed."
fi
