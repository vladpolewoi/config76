#!/bin/bash

# Check if tmux is installed
if ! command -v tmux &>/dev/null; then
  echo "📦 'tmux' not found. Installing..."

  # Use yay if available, else fall back to pacman
  if command -v yay &>/dev/null; then
    yay -S --noconfirm tmux
  else
    sudo pacman -S --needed --noconfirm tmux
  fi

  echo "✅ 'tmux' installed."
else
  echo "✅ 'tmux' is already installed."
fi

