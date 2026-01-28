#!/bin/bash

PIDFILE="$HOME/.cache/nerd-dictation.pid"
MODEL_DIR="$HOME/.local/share/vosk-models/vosk-model-en-us-0.22"

# Check if nerd-dictation is installed
if ! command -v nerd-dictation &>/dev/null; then
    notify-send "Dictation" "nerd-dictation not installed" -i dialog-error
    exit 1
fi

# Check if model exists
if [ ! -d "$MODEL_DIR" ]; then
    notify-send "Dictation" "Model not found at $MODEL_DIR" -i dialog-error
    exit 1
fi

# Toggle dictation
if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if kill -0 "$PID" 2>/dev/null; then
        nerd-dictation end
        rm "$PIDFILE"
        notify-send "Dictation" "Stopped" -i microphone-sensitivity-muted
        exit 0
    fi
    rm "$PIDFILE"
fi

# Start dictation
nerd-dictation begin \
    --vosk-model-dir="$MODEL_DIR" \
    --simulate-input-tool=WTYPE \
    --continuous \
    --numbers-as-digits \
    --input=SOX &

echo $! > "$PIDFILE"

sleep 0.5
if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    notify-send "Dictation" "Listening..." -i audio-input-microphone
else
    rm -f "$PIDFILE"
    notify-send "Dictation" "Failed to start" -i dialog-error
fi
