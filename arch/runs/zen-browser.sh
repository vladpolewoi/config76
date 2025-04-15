#!/bin/bash

set -e

echo "🌿 Installing Zen Browser via yay..."

# Check if yay is installed
if ! command -v yay &> /dev/null; then
  echo "📦 yay not found. Installing..."
  sudo pacman -S --needed git base-devel

  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
else
  echo "✅ yay already installed."
fi

# Install zen-browser-bin from AUR
yay -S --noconfirm zen-browser-bin

echo "🎉 Zen Browser installed!"
echo "💡 Launch it with: zen-browser"

