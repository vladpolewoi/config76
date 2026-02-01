#!/bin/bash

set -e

echo "=-=-=-=- Installing NVIDIA Drivers -=-=-=-="

# Install linux headers (required for dkms)
sudo pacman -S --needed --noconfirm linux-headers

if ! command -v yay &> /dev/null; then
  sudo pacman -S --needed base-devel

  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
fi

# Install nvidia-580xx-dkms from AUR
yay -S --noconfirm nvidia-580xx-dkms

echo "=-=-=-=- NVIDIA Drivers Installed -=-=-=-="
echo "⚠️  Reboot required for drivers to take effect"
