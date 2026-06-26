#!/bin/bash
set -e
if ! command -v pandoc &>/dev/null; then
  echo "📦 Installing pandoc (AUR pandoc-bin)..."
  yay -S --noconfirm pandoc-bin
else
  echo "✅ pandoc already installed."
fi
