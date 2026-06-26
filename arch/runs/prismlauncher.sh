#!/bin/bash
if ! command -v prismlauncher &>/dev/null; then
  echo "📦 'prismlauncher' not found. Installing..."
  sudo pacman -S --needed --noconfirm prismlauncher
  echo "✅ 'prismlauncher' installed."
else
  echo "✅ 'prismlauncher' is already installed."
fi
