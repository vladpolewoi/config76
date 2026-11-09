#!/bin/sh
# cuts.sh <mp4> [thresh] — scene-cut timestamps
in=$1; t=${2:-0.3}
ffmpeg -hide_banner -nostats -loglevel info -i "$in" -vf "select='gt(scene,$t)',showinfo" -an -f null - 2>&1 | grep 'Parsed_showinfo' | grep -o 'pts_time:[0-9.]*' | cut -d: -f2 | awk '{printf "%.1f ", $1} END {print ""}'
