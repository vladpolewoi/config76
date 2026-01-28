#!/bin/bash

set -e

echo "🔧 Installing dictation packages..."
yay -S --needed --noconfirm nerd-dictation-git python-vosk sox wtype

MODEL_DIR="$HOME/.local/share/vosk-models"
MODEL_NAME="vosk-model-en-us-0.22"
MODEL_URL="https://alphacephei.com/vosk/models/${MODEL_NAME}.zip"

echo "📁 Creating model directory..."
mkdir -p "$MODEL_DIR"

if [ ! -d "$MODEL_DIR/$MODEL_NAME" ]; then
    echo "📥 Downloading vosk model (1.8GB - this may take a while)..."
    cd "$MODEL_DIR"
    curl -LO "$MODEL_URL"
    echo "📦 Extracting model..."
    unzip "${MODEL_NAME}.zip"
    rm "${MODEL_NAME}.zip"
else
    echo "✅ Model already exists, skipping download"
fi

echo "🎉 Done! Press F8 to toggle dictation."
