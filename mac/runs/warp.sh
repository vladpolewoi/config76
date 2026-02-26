#!/bin/bash

set -e

header() { echo "==== $1 ===="; }; success() { echo "  ✓ $1"; }; skip() { echo "  - SKIP: $1"; }; info() { echo "  $1"; }

header "Installing Warp"

if brew list --cask warp &>/dev/null; then
  skip "Warp already installed"
  exit 0
fi

brew install --cask warp

success "Warp installed"
