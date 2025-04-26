#!/bin/bash

VOL=$(pamixer --get-volume)
MUTED=$(pamixer --get-mute)

# Make volume bar (10 steps)
BAR_WIDTH=10
FILLED=$(( VOL * BAR_WIDTH / 100 ))
EMPTY=$(( BAR_WIDTH - FILLED ))
BAR="$(printf '█%.0s' $(seq 1 $FILLED))$(printf '░%.0s' $(seq 1 $EMPTY))"

if [ "$MUTED" = "true" ]; then
  notify-send -r 91190 -t 1000 "🔇 Muted"
else
  notify-send -r 91190 -t 1000 "$BAR  ${VOL}%"
fi

