#!/bin/bash
set -e

if brew list tmux &>/dev/null; then
  echo "tmux already installed"
else
  brew install tmux
fi
