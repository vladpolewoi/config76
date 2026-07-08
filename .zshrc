# macOS: put Homebrew ahead of system paths. path_helper (/etc/zprofile) appends
# /opt/homebrew last, leaving system bash 3.2 first — too old for the sync scripts
# (they use bash 4+ features like `local -n`). Re-prepend so brew's bash 5 wins.
if [[ "$OSTYPE" == darwin* ]] && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$HOME/.local/scripts:$PATH"

# Export gitignored MCP/tool secrets (consult, telegram, projects) so `claude`
# and its stdio MCP servers can expand the ${VAR} refs in claude/mcp.json.
# The platform file lives next to this one: <repo>/{mac,arch}/secrets.env.
_c76_root="${${(%):-%N}:A:h}"
if [[ "$OSTYPE" == darwin* ]]; then _c76_sec="$_c76_root/mac/secrets.env"
else _c76_sec="$_c76_root/arch/secrets.env"; fi
[[ -f "$_c76_sec" ]] && { set -a; source "$_c76_sec"; set +a; }
unset _c76_root _c76_sec

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="refined"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
