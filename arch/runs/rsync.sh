#!/bin/bash
if ! command -v rsync &>/dev/null; then
  echo "📦 'rsync' not found. Installing..."
  sudo pacman -S --needed --noconfirm rsync
  echo "✅ 'rsync' installed."
else
  echo "✅ 'rsync' is already installed."
fi
