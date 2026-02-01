#!/bin/bash

echo "📦 Installing wf-recorder (Wayland screen recorder)..."

sudo pacman -S --needed --noconfirm wf-recorder

echo "✅ 'wf-recorder' installed."
echo "💡 Usage: wf-recorder -f output.mp4"
echo "💡 With audio: wf-recorder -a -f output.mp4"
