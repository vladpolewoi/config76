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

GFONTS="https://raw.githubusercontent.com/google/fonts/main/ofl"

echo "🔤 Installing Shantell Sans..."
curl -Lo "$FONT_DIR/ShantellSans[BNCE,INFM,SPAC,wght].ttf" "$GFONTS/shantellsans/ShantellSans%5BBNCE%2CINFM%2CSPAC%2Cwght%5D.ttf"
curl -Lo "$FONT_DIR/ShantellSans-Italic[BNCE,INFM,SPAC,wght].ttf" "$GFONTS/shantellsans/ShantellSans-Italic%5BBNCE%2CINFM%2CSPAC%2Cwght%5D.ttf"

echo "🔤 Installing Space Grotesk..."
curl -Lo "$FONT_DIR/SpaceGrotesk[wght].ttf" "$GFONTS/spacegrotesk/SpaceGrotesk%5Bwght%5D.ttf"

echo "🔤 Installing Nunito..."
curl -Lo "$FONT_DIR/Nunito[wght].ttf" "$GFONTS/nunito/Nunito%5Bwght%5D.ttf"
curl -Lo "$FONT_DIR/Nunito-Italic[wght].ttf" "$GFONTS/nunito/Nunito-Italic%5Bwght%5D.ttf"

echo "🧹 Cleaning up..."
fc-cache -fv
rm -rf "$TMP_DIR"

echo "✅ JetBrainsMono, Hack, Shantell Sans, Space Grotesk, Nunito installed to $FONT_DIR"

