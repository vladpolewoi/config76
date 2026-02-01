#!/bin/bash

echo "📦 Installing Rust..."

sudo pacman -S --needed --noconfirm rust

echo "✅ 'rust' installed."
echo "💡 Rust version: $(rustc --version)"
