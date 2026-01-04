#!/bin/bash

PIDFILE="$HOME/.cache/screen-record.pid"

if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill -INT "$PID"
        rm "$PIDFILE"
        notify-send "Screen Recording" "Recording stopped" -i media-record
        exit 0
    fi
    rm "$PIDFILE"
fi

REGION=$(slurp 2>&1)
if [ $? -ne 0 ] || [ -z "$REGION" ]; then
    notify-send "Screen Recording" "Cancelled" -i dialog-error
    exit 1
fi

OUTPUT="$HOME/Videos/recording-$(date +%Y%m%d_%H%M%S).mp4"
mkdir -p "$HOME/Videos" "$HOME/.cache"

wf-recorder -g "$REGION" -c libx264 -a -f "$OUTPUT" </dev/null &>/dev/null &
echo $! > "$PIDFILE"

sleep 0.5
if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    notify-send "Screen Recording" "Recording started - Press SUPER+SHIFT+R to stop" -i media-record
else
    rm -f "$PIDFILE"
    notify-send "Screen Recording" "Failed to start" -i dialog-error
fi
