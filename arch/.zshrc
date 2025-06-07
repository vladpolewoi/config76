export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"  # Nerd Font required
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh

# Custom aliases
alias ll="ls -la"

# bun completions
[ -s "/home/user76/.bun/_bun" ] && source "/home/user76/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Map git
alias gch='git checkout'

export EDITOR="nvim"

