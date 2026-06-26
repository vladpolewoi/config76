#!/bin/bash
if ! command -v gh &>/dev/null; then
  echo "📦 'github-cli' not found. Installing..."
  sudo pacman -S --needed --noconfirm github-cli
  echo "✅ 'github-cli' installed."
else
  echo "✅ 'github-cli' is already installed."
fi
