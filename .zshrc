export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="refined"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)

source $ZSH/oh-my-zsh.sh

source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
