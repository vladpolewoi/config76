#!/bin/sh
# sheet.sh <mp4> <out.jpg> [cols rows]  — N evenly spaced frames tiled, 320px per tile wide,
# then the whole sheet fitted inside 1600x1600 (a portrait reel's 5x4 sheet is ~1608x2278 before the fit)
in=$1; out=$2; cols=${3:-5}; rows=${4:-4}; n=$((cols*rows))
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in")
ffmpeg -v error -y -i "$in" -vf "fps=$n/$dur,scale=320:-2,tile=${cols}x${rows}:padding=2:color=black,scale=1600:1600:force_original_aspect_ratio=decrease:flags=lanczos" -frames:v 1 -q:v 4 "$out"
