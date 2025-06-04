#!/bin/bash

set -e

sudo pacman -S --noconfirm unzip noto-fonts-emoji

FONT_DIR="$HOME/.local/share/fonts"
TMP_DIR=$(mktemp -d)


mkdir -p "$FONT_DIR"
cd "$TMP_DIR"

echo "🔤 Installing JetBrainsMono Nerd Font from GitHub..."
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d "$FONT_DIR"

echo "🔤 Installing Hack Nerd Font from GitHub..."
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
unzip -q Hack.zip -d "$FONT_DIR"

echo "🧹 Cleaning up..."
fc-cache -fv
rm -rf "$TMP_DIR"

echo "✅ JetBrainsMono, Hack Nerd Font installed to $FONT_DIR"

