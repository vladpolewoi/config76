#!/bin/bash

set -e

sudo pacman -S --noconfirm openssh

# Copy SSH config
script_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
mkdir -p "$HOME/.ssh"
cp "$script_dir/../.ssh/config" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"

KEY_COMMENT="vlad.polewoi1@gmail.com"
KEY_FILE="$HOME/.ssh/id_ed25519"

echo "🔐 Checking for existing SSH key..."

# 1. Generate SSH key if it doesn't exist
if [[ ! -f "$KEY_FILE" ]]; then
  echo "📦 Generating new ed25519 SSH key..."
  ssh-keygen -t ed25519 -C "$KEY_COMMENT" -f "$KEY_FILE" -N ""
else
  echo "✅ SSH key already exists at $KEY_FILE"
fi

# 2. Ensure ssh-agent is running
echo "🧠 Starting ssh-agent..."
eval "$(ssh-agent -s)"

# 3. Add key to agent
echo "➕ Adding SSH key to agent..."
ssh-add "$KEY_FILE"

# 4. Copy public key to clipboard
cat "$KEY_FILE.pub" | wl-copy
echo "📋 Public key copied to clipboard (Wayland)"

# 5. Open GitHub SSH key page
if command -v xdg-open &>/dev/null; then
  echo "🌐 Opening GitHub SSH keys page..."
  xdg-open "https://github.com/settings/ssh/new"
else
  echo "🔗 Open this page to add the key manually:"
  echo "https://github.com/settings/ssh/new"
fi

echo "✅ Done! Paste your key into GitHub."

