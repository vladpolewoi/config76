#!/bin/bash

echo "📦 Installing XDG desktop portals for Hyprland..."

sudo pacman -S --needed --noconfirm \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-hyprland \
  libappindicator-gtk3

echo "✅ Desktop portals and system tray support installed."
