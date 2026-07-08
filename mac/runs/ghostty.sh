#!/bin/bash
set -e

if brew list --cask ghostty &>/dev/null; then
  echo "ghostty already installed"
else
  brew install --cask ghostty
fi

# Ensure local override file exists so config-file directive doesn't error
if [ ! -f ~/.config/ghostty/local.conf ]; then
  mkdir -p ~/.config/ghostty
  touch ~/.config/ghostty/local.conf
fi
