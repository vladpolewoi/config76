#!/usr/bin/env bash

# bootstrap.sh — fresh machine setup
# Usage: curl -fsSL https://raw.githubusercontent.com/vladpolewoi/config76/main/bootstrap.sh | bash
# Or:    bash bootstrap.sh

set -e

REPO="https://github.com/vladpolewoi/config76.git"
CLONE_DIR="$HOME/code/config76"

# ─── Helpers ────────────────────────────────────────────────────────────────

info() { echo "  [→] $*"; }
ok()   { echo "  [✓] $*"; }
warn() { echo "  [!] $*"; }

header() {
  echo ""
  echo "══════════════════════════════════════════"
  echo "  $*"
  echo "══════════════════════════════════════════"
  echo ""
}

# ─── Step 1: Xcode Command Line Tools ───────────────────────────────────────

header "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
  ok "Already installed"
else
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  # Wait for installation to complete
  until xcode-select -p &>/dev/null; do sleep 5; done
  ok "Installed"
fi

# ─── Step 2: Homebrew ───────────────────────────────────────────────────────

header "Homebrew"

if command -v brew &>/dev/null; then
  ok "Already installed"
else
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for Apple Silicon
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  ok "Installed"
fi

# ─── Step 3: Git ────────────────────────────────────────────────────────────

header "Git"

if command -v git &>/dev/null; then
  ok "Already installed ($(git --version))"
else
  info "Installing git..."
  brew install git
  ok "Installed"
fi

# ─── Step 4: Clone repo ─────────────────────────────────────────────────────

header "config76 repo"

if [[ -d "$CLONE_DIR/.git" ]]; then
  ok "Already cloned at $CLONE_DIR"
  info "Pulling latest..."
  git -C "$CLONE_DIR" pull
else
  info "Cloning into $CLONE_DIR..."
  mkdir -p "$(dirname "$CLONE_DIR")"
  git clone "$REPO" "$CLONE_DIR"
  ok "Cloned"
fi

# ─── Step 5: Run installer ──────────────────────────────────────────────────

header "Running mac installer"

cd "$CLONE_DIR/mac"
bash install.sh
