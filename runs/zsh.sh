#!/bin/bash

set -e

echo "🧙 Installing ZSH and configuring plugins..."

# 1. Install ZSH if not present
if ! command -v zsh &>/dev/null; then
  echo "🔧 Installing zsh..."
  sudo apt update
  sudo apt install -y zsh
fi

# 2. Set ZSH as default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "🔁 Setting ZSH as default shell..."
  chsh -s "$(which zsh)"
fi

# 3. Install Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "📦 Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 4. Install plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

## autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "✨ Installing autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

## syntax highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  echo "🖍️ Installing syntax highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

## fzf-tab (optional: fuzzy tab completion)
if [[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]]; then
  echo "🔍 Installing fzf-tab..."
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
fi

# 5. Configure ~/.zshrc
echo "🔧 Updating .zshrc..."

sed -i 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' ~/.zshrc
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)/' ~/.zshrc

# If plugins line is missing, add it
if ! grep -q '^plugins=' ~/.zshrc; then
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)' >> ~/.zshrc
fi

echo 'source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
echo 'source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc

echo "✅ ZSH is installed, configured, and ready!"
echo "💡 Restart your terminal or run \`exec zsh\` to start using it."

