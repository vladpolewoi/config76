#!/bin/bash
set -e

if brew list --cask ghostty &>/dev/null; then
  echo "ghostty already installed"
else
  brew install --cask ghostty
fi
