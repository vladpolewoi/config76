#!/usr/bin/env bash
# yt-dlp — added by sync/apply.sh, review before running.
set -e
if ! pacman -Qi yt-dlp &>/dev/null && ! command -v yt-dlp &>/dev/null; then
  sudo pacman -S --needed --noconfirm yt-dlp || yay -S --needed --noconfirm yt-dlp
fi
