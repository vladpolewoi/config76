#!/usr/bin/env bash
# cloudflare-warp-bin — added by sync/apply.sh, review before running.
set -e
if ! pacman -Qi cloudflare-warp-bin &>/dev/null && ! command -v cloudflare-warp-bin &>/dev/null; then
  sudo pacman -S --needed --noconfirm cloudflare-warp-bin || yay -S --needed --noconfirm cloudflare-warp-bin
fi

# Waybar custom/warp widget depends on the daemon + a device registration.
sudo systemctl enable --now warp-svc
warp-cli --accept-tos registration show &>/dev/null || warp-cli --accept-tos registration new
