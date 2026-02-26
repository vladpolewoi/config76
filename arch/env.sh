#!/usr/bin/env bash

script_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

filter=""
dry="0"

# Parse arguments
while [[ $# > 0 ]]; do
  if [[ $1 == "--dry" ]]; then
    dry="1"
  else
    filter="$1"
  fi
  shift
done

# Log with prefix
log() {
  if [[ $dry == "1" ]]; then
    echo "[DRY_RUN]: $@"
  else
    echo "$@"
  fi
}

# Execute with dry-run check and logging
execute() {
  log "execute $@"

  if [[ $dry == "1" ]]; then
    return
  fi
  "$@"
}

log "-#@ dev @#-"

# Merge source dir into target (overlay — overwrites matching files, preserves the rest)
copy_dir() {
  local from=$1
  local to=$2

  pushd "$from" > /dev/null
  local dirs=$(find . -mindepth 1 -maxdepth 1 -type d)
  for dir in $dirs; do
    local name="${dir#./}"
    execute mkdir -p "$to/$name"
    execute cp -rf "$name/." "$to/$name/"
  done
  popd > /dev/null
}

copy_file() {
  local from=$1
  local to=$2

  execute mkdir -p "$to"
  execute cp -f "$from" "$to/"
}

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
copy_dir "$script_dir/.config" "$XDG_CONFIG_HOME"
copy_dir "$script_dir/.local" "$HOME/.local"
copy_dir "$script_dir/.claude" "$HOME/.claude"
copy_file "$script_dir/.zshrc" "$HOME"
copy_file "$script_dir/.zprofile" "$HOME"
# ── SSH config — generated from template + secrets.env ──
SECRETS="$script_dir/secrets.env"
SSH_TEMPLATE="$script_dir/.ssh/config"
SSH_TARGET="$HOME/.ssh/config"

if [[ ! -f "$SECRETS" ]]; then
  echo "WARN: $SECRETS not found — copy secrets.env.example and fill in values. Skipping SSH config."
else
  execute mkdir -p "$HOME/.ssh"
  execute bash -c "set -a && source '$SECRETS' && set +a && envsubst < '$SSH_TEMPLATE' > '$SSH_TARGET'"
  execute chmod 600 "$SSH_TARGET"
  echo "SSH config generated at $SSH_TARGET"
fi
copy_file "$script_dir/CLAUDE.md" "$HOME"
copy_file "$script_dir/claude-models.sh" "$HOME/.claude"
copy_file "$script_dir/.claude/mcp.json" "$HOME/.claude"

