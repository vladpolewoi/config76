#!/bin/bash

set -e

# Source style helpers (fallback to plain echo)
_style_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" 2>/dev/null && pwd)"
[[ -f "$_style_dir/style.sh" ]] && source "$_style_dir/style.sh"
type header &>/dev/null || { header() { echo "==== $1 ===="; }; success() { echo "  ✓ $1"; }; skip() { echo "  - SKIP: $1"; }; info() { echo "  $1"; }; }

header "Installing Warp"

if brew list --cask warp &>/dev/null; then
  skip "Warp already installed"
  info "$(brew info --cask warp | head -1)"
  exit 2
fi

brew install --cask warp

success "Warp installed"
