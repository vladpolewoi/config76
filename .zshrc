export PATH="$HOME/.local/bin:$HOME/.local/scripts:$PATH"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="refined"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
