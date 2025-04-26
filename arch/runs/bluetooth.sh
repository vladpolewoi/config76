#!/bin/bash

set -e

echo "🔧 Installing Bluetooth packages..."
sudo pacman -S --needed --noconfirm bluez bluez-utils 

echo "🚀 Enabling and starting bluetooth.service..."
sudo systemctl enable --now bluetooth.service

echo "🔧 Installing Audio packages..."
sudo pacman -S pipewire pipewire-pulse wireplumber pipewire-alsa pipewire-audio pipewire-jack
sudo pacman -S --noconfirm --needed pamixer 

echo "🚀 Enabling and starting audio.service..."
systemctl --user enable --now pipewire
systemctl --user enable --now pipewire-pulse
systemctl --user enable --now wireplumber

echo "🎉 Done!"

