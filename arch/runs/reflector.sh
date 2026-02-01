#!/bin/bash

echo "📦 Installing reflector (mirrorlist optimizer)..."

sudo pacman -S --needed --noconfirm reflector

echo "✅ 'reflector' installed."
echo "💡 Usage: sudo reflector --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
