#!/bin/bash
if ! command -v aria2c &>/dev/null; then
  echo "📦 'aria2' not found. Installing..."
  sudo pacman -S --needed --noconfirm aria2
  echo "✅ 'aria2' installed."
else
  echo "✅ 'aria2' is already installed."
fi
