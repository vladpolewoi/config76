#!/bin/bash

set -e

header() { echo "==== $1 ===="; }; success() { echo "  ✓ $1"; }; skip() { echo "  - SKIP: $1"; }

header "Installing fonts"

if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
  skip "JetBrainsMono Nerd Font already installed"
else
  brew install --cask font-jetbrains-mono-nerd-font
  success "JetBrainsMono Nerd Font installed"
fi
