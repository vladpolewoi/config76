#!/bin/bash
if ! command -v yq &>/dev/null; then
  echo "📦 'go-yq' not found. Installing..."
  sudo pacman -S --needed --noconfirm go-yq
  echo "✅ 'go-yq' installed."
else
  echo "✅ 'go-yq' is already installed."
fi
