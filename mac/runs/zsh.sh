#!/bin/bash
set -e

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── oh-my-zsh ──
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "oh-my-zsh already installed"
else
  echo "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ── zsh-autosuggestions ──
if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "zsh-autosuggestions already installed"
else
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# ── zsh-syntax-highlighting ──
if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  echo "zsh-syntax-highlighting already installed"
else
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ── fzf-tab ──
if [[ -d "$ZSH_CUSTOM/plugins/fzf-tab" ]]; then
  echo "fzf-tab already installed"
else
  echo "Installing fzf-tab..."
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
fi

# ── fzf (required by fzf-tab) ──
if brew list fzf &>/dev/null; then
  echo "fzf already installed"
else
  echo "Installing fzf..."
  brew install fzf
fi
