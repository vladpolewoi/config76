#!/bin/bash

set -e

sudo pacman -S --noconfirm unzip noto-fonts-emoji

FONT_DIR="$HOME/.local/share/fonts"
TMP_DIR=$(mktemp -d)

echo "🔤 Installing JetBrainsMono Nerd Font from GitHub..."

mkdir -p "$FONT_DIR"
cd "$TMP_DIR"

curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d "$FONT_DIR"

echo "🧹 Cleaning up..."
fc-cache -fv
rm -rf "$TMP_DIR"

echo "✅ JetBrainsMono Nerd Font installed to $FONT_DIR"

