#!/bin/bash

echo "🔧 Installing screenshot & annotation tools..."

sudo pacman -Syu --needed \
  flameshot \
  grim \
  slurp \
  swappy \
  wl-clipboard

echo "✅ Installed: flameshot, grim, slurp, swappy, wl-clipboard"

