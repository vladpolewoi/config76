#!/bin/bash

# Check if cmatrix is installed
if ! command -v cmatrix &>/dev/null; then
  echo "📦 'cmatrix' not found. Installing..."
  sudo pacman -S --needed --noconfirm cmatrix
  echo "✅ 'cmatrix' installed."
else
  echo "✅ 'cmatrix' is already installed."
fi
