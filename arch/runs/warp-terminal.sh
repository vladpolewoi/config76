#!/bin/bash

set -e

echo "=-=-=-=- Installing Warp Terminal -=-=-=-="

if ! command -v yay &> /dev/null; then
  sudo pacman -S --needed base-devel

  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
fi

yay -S --noconfirm warp-terminal

echo "=-=-=-=- Warp Terminal Installed -=-=-=-="
