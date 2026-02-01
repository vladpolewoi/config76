#!/bin/bash

set -e

echo "=-=-=-=- Installing Claude Code -=-=-=-="

if ! command -v yay &> /dev/null; then
  sudo pacman -S --needed base-devel

  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
fi

yay -S --noconfirm claude-code

echo "=-=-=-=- Claude Code Installed -=-=-=-="
