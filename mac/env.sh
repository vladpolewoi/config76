#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

dry="0"

while [[ $# > 0 ]]; do
  [[ $1 == "--dry" ]] && dry="1"
  shift
done

log() {
  [[ $dry == "1" ]] && echo "[DRY_RUN]: $@" || echo "$@"
}

execute() {
  log "  $@"
  [[ $dry == "1" ]] && return
  "$@"
}

# Symlink a directory into target (e.g. .config/nvim → repo/.config/nvim)
link_dir() {
  local from="$1"
  local to="$2"

  [[ -d "$from" ]] || return 0

  for dir in "$from"/*/; do
    [[ -d "$dir" ]] || continue
    local name="$(basename "$dir")"
    local target="$to/$name"

    if [[ -L "$target" ]]; then
      execute rm "$target"
    elif [[ -d "$target" ]]; then
      execute rm -rf "$target"
    fi

    execute ln -s "$dir" "$target"
  done
}

# Symlink a single file
link_file() {
  local from="$1"
  local to="$2"

  [[ -f "$from" ]] || return 0

  local dir="$(dirname "$to")"
  execute mkdir -p "$dir"

  if [[ -L "$to" ]]; then
    execute rm "$to"
  elif [[ -f "$to" ]]; then
    execute mv "$to" "$to.backup"
  fi

  execute ln -s "$from" "$to"
}

log "═══ config76 mac env ═══"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
execute mkdir -p "$XDG_CONFIG_HOME"

# ── Shared configs (nvim, tmux, ghostty) ──
log ""
log ">> Shared configs"
link_dir "$ROOT_DIR/.config" "$XDG_CONFIG_HOME"
link_dir "$ROOT_DIR/.local" "$HOME/.local"
link_file "$ROOT_DIR/.zshrc" "$HOME/.zshrc"

# ── Mac-specific configs (yabai, skhd) ──
log ""
log ">> Mac configs"
link_dir "$SCRIPT_DIR/.config" "$XDG_CONFIG_HOME"
link_dir "$SCRIPT_DIR/.claude" "$HOME/.claude"

log ""
log "done"
