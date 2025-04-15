#!/bin/bash

set -e

echo "🧙 Installing ZSH and configuring plugins..."

# 1. Install ZSH if not present
if ! command -v zsh &>/dev/null; then
  echo "🔧 Installing zsh..."
  sudo pacman -S --needed zsh
fi

# 2. Set ZSH as default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "🔁 Setting ZSH as default shell..."
  chsh -s "$(which zsh)"
fi

# 3. Install Oh My Zsh (without changing .zshrc if it exists)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "📦 Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 4. Install plugins
echo "✨ Installing ZSH plugins..."

# Autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Syntax highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Completions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# 5. Apply basic .zshrc config if it doesn’t exist
if [[ ! -f "$HOME/.zshrc" ]]; then
  echo "📄 Creating .zshrc..."
  cat <<EOF > ~/.zshrc
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"  # Nerd Font required
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source \$ZSH/oh-my-zsh.sh

# Custom aliases
alias ll="ls -la"
alias gs="git status"
EOF
fi

echo "✅ ZSH setup complete! Restart terminal or run: exec zsh"

