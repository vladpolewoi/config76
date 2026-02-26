#!/bin/bash

set -e

header() { echo "==== $1 ===="; }; success() { echo "  ✓ $1"; }; skip() { echo "  - SKIP: $1"; }

header "Installing Arc"

if brew list --cask arc &>/dev/null; then
  skip "Arc already installed"
  exit 0
fi

brew install --cask arc

success "Arc installed"
