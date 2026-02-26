#!/bin/bash

set -e

header() { echo "==== $1 ===="; }; success() { echo "  ✓ $1"; }; skip() { echo "  - SKIP: $1"; }; info() { echo "  $1"; }; step() { echo ">> $1"; }; warn() { echo "WARN: $1"; }

header "Installing yabai + skhd"

# ── Install yabai ──
if brew list yabai &>/dev/null; then
  skip "yabai already installed"
else
  brew install koekeishiya/formulae/yabai
  success "yabai installed"
fi

# ── Install skhd ──
if brew list skhd &>/dev/null; then
  skip "skhd already installed"
else
  brew install koekeishiya/formulae/skhd
  success "skhd installed"
fi

# ── Start services ──
step "Starting yabai"
yabai --start-service 2>/dev/null || brew services start yabai 2>/dev/null || true
success "yabai started"

step "Starting skhd"
skhd --start-service 2>/dev/null || brew services start skhd 2>/dev/null || true
success "skhd started"

info ""
info "Hotkeys:"
info "  fn/globe + hjkl    Focus window"
info "  alt + hjkl         Focus window (alt)"
info "  alt+shift + hjkl   Swap windows"
info "  alt + f             Maximize"
info "  alt + t             Toggle float"
info "  alt + 1-6           Switch space"
info ""
info "Grant Accessibility permissions to both yabai and skhd:"
info "  System Settings > Privacy & Security > Accessibility"
