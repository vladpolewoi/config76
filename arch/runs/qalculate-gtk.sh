#!/bin/bash
if ! command -v qalculate-gtk &>/dev/null; then
  echo "📦 'qalculate-gtk' not found. Installing..."
  sudo pacman -S --needed --noconfirm qalculate-gtk
  echo "✅ 'qalculate-gtk' installed."
else
  echo "✅ 'qalculate-gtk' is already installed."
fi
