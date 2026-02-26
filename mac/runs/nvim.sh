#!/bin/bash
set -e

if brew list neovim &>/dev/null; then
  echo "neovim already installed"
else
  brew install neovim
fi
