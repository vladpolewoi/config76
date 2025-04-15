#!/bin/bash

set -e

echo "📦 Installing Obsidian on Arch..."

# Check if yay is installed
if command -v yay &>/dev/null; then
  echo "✅ yay found. Installing Obsidian from AUR..."
  yay -S --noconfirm obsidian
else
  echo "⚠️ yay not found. Falling back to AppImage install..."

  APP_DIR="$HOME/Apps"
  BIN_DIR="$HOME/.local/bin"
  mkdir -p "$APP_DIR" "$BIN_DIR"

  echo "⬇️  Downloading latest Obsidian AppImage..."
  curl -L -o "$APP_DIR/Obsidian.AppImage" \
    https://github.com/obsidianmd/obsidian-releases/releases/latest/download/Obsidian-1.5.12.AppImage

  chmod +x "$APP_DIR/Obsidian.AppImage"

  # Create symlink for easier launch
  ln -sf "$APP_DIR/Obsidian.AppImage" "$BIN_DIR/obsidian"

  echo "✅ Obsidian AppImage installed to $APP_DIR"
  echo "💡 You can run it with: obsidian"
fi

