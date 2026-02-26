#!/bin/bash

set -e

KEY_COMMENT=$(gum input --placeholder "your@email.com" --prompt "GitHub email: ")
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

# 3. Add key to agent (macOS Keychain)
echo "➕ Adding SSH key to agent..."
ssh-add --apple-use-keychain "$KEY_FILE"

# 4. Copy public key to clipboard
pbcopy < "$KEY_FILE.pub"
echo "📋 Public key copied to clipboard"

# 5. Open GitHub SSH key page
echo "🌐 Opening GitHub SSH keys page..."
open "https://github.com/settings/ssh/new"

echo "✅ Done! Paste your key into GitHub."
