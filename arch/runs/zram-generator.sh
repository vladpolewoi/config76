#!/bin/bash
if ! pacman -Qq zram-generator &>/dev/null; then
  echo "📦 'zram-generator' not found. Installing..."
  sudo pacman -S --needed --noconfirm zram-generator
  echo "✅ 'zram-generator' installed."
else
  echo "✅ 'zram-generator' is already installed."
fi
