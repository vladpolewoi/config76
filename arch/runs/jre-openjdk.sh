#!/bin/bash
if ! pacman -Qq jre-openjdk &>/dev/null; then
  echo "📦 'jre-openjdk' not found. Installing..."
  sudo pacman -S --needed --noconfirm jre-openjdk
  echo "✅ 'jre-openjdk' installed."
else
  echo "✅ 'jre-openjdk' is already installed."
fi
