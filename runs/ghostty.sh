#!/bin/bash

set -e

echo "🧙 Installing Ghostty (AppImage version)..."

# Create bin dir if not exists
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Get latest release info from GitHub
echo "🔍 Fetching latest release info..."
LATEST_URL=$(curl -s https://api.github.com/repos/pkgforge-dev/ghostty-appimage/releases/latest | \
  jq -r '.assets[] | select(.name | test("x86_64.AppImage$")) | .browser_download_url')

if [[ -z "$LATEST_URL" ]]; then
  echo "❌ Could not find AppImage download URL."
  exit 1
fi

FILENAME=$(basename "$LATEST_URL")
DEST="$INSTALL_DIR/$FILENAME"

echo "⬇️  Downloading $FILENAME..."
curl -L "$LATEST_URL" -o "$DEST"

echo "🧾 Making it executable..."
chmod +x "$DEST"

# Optional symlink to make launch command shorter
ln -sf "$DEST" "$INSTALL_DIR/ghostty"

echo "🧾 Creating .desktop launcher..."
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/ghostty.desktop <<EOF
[Desktop Entry]
Name=Ghostty
Exec=$INSTALL_DIR/ghostty
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
StartupNotify=true
Terminal=false
EOF

chmod +x ~/.local/share/applications/ghostty.desktop

# Optional: Set as default terminal
echo "🔧 Setting Ghostty as default terminal..."
gsettings set org.gnome.desktop.default-applications.terminal exec "$INSTALL_DIR/ghostty"
gsettings set org.gnome.desktop.default-applications.terminal exec-arg "-e"

echo "✅ Ghostty AppImage installed and set as default terminal."

