#!/bin/bash

echo "📦 Installing Node.js ecosystem..."

sudo pacman -S --needed --noconfirm nodejs npm yarn

echo "✅ 'nodejs', 'npm', and 'yarn' installed."
echo "💡 Node version: $(node --version)"
