#!/bin/bash

set -e

echo "=-=-=-=- Installing Brave -=-=-=-="

if ! command -v yay &> /dev/null; then
  sudo pacman -S --needed git base-devel

  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
fi

yay -S --needed --noconfirm brave-bin

echo "=-=-=-=- Brave Installed (launch: brave) -=-=-=-="
