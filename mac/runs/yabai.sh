#!/bin/bash

set -e

# Source style helpers (fallback to plain echo)
_style_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" 2>/dev/null && pwd)"
[[ -f "$_style_dir/style.sh" ]] && source "$_style_dir/style.sh"
type header &>/dev/null || { header() { echo "==== $1 ===="; }; success() { echo "  ✓ $1"; }; skip() { echo "  - SKIP: $1"; }; info() { echo "  $1"; }; step() { echo ">> $1"; }; warn() { echo "WARN: $1"; }; }

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

# ── Symlink configs ──
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAC_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# yabai config
step "Linking yabai config"
YABAI_SOURCE="$MAC_ROOT/.config/yabai"
YABAI_TARGET="$HOME/.config/yabai"
mkdir -p "$HOME/.config"

if [ -L "$YABAI_TARGET" ]; then
  rm "$YABAI_TARGET"
elif [ -e "$YABAI_TARGET" ]; then
  mv "$YABAI_TARGET" "$YABAI_TARGET.backup"
  warn "Backed up: $YABAI_TARGET -> $YABAI_TARGET.backup"
fi

ln -s "$YABAI_SOURCE" "$YABAI_TARGET"
chmod +x "$YABAI_SOURCE/yabairc"
success "Linked ~/.config/yabai"

# skhd config
step "Linking skhd config"
SKHD_SOURCE="$MAC_ROOT/.config/skhd"
SKHD_TARGET="$HOME/.config/skhd"

if [ -L "$SKHD_TARGET" ]; then
  rm "$SKHD_TARGET"
elif [ -e "$SKHD_TARGET" ]; then
  mv "$SKHD_TARGET" "$SKHD_TARGET.backup"
  warn "Backed up: $SKHD_TARGET -> $SKHD_TARGET.backup"
fi

ln -s "$SKHD_SOURCE" "$SKHD_TARGET"
success "Linked ~/.config/skhd"

# ── Start services ──
step "Starting yabai"
yabai --start-service 2>/dev/null || brew services start yabai 2>/dev/null || true
success "yabai started"

step "Starting skhd"
skhd --start-service 2>/dev/null || brew services start skhd 2>/dev/null || true
success "skhd started"

info ""
info "Hotkeys:"
info "  alt + hjkl         Focus window"
info "  alt+shift + hjkl   Swap windows"
info "  alt + f             Maximize"
info "  alt + t             Toggle float"
info "  alt + 1-6           Switch space"
info ""
info "Grant Accessibility permissions to both yabai and skhd:"
info "  System Settings > Privacy & Security > Accessibility"
