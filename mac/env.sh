#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

DRY=0
[[ "${1}" == "--dry" ]] && DRY=1

# ─── Helpers ────────────────────────────────────────────────────────────────

info() { gum log --level info  "$@"; }
warn() { gum log --level warn  "$@"; }
skip() { gum log --level debug "$@"; }

run() {
  if [[ $DRY -eq 1 ]]; then
    gum log --level debug "dry:" cmd "$*"
  else
    "$@"
  fi
}

section() {
  echo ""
  gum style --foreground 99 --bold "$1"
}

# Symlink a single directory.
# If a real dir already exists at target it is backed up first.
# If a symlink already exists it is updated.
symlink_dir() {
  local from="$1"
  local to="$2"

  [[ -d "$from" ]] || return 0

  run mkdir -p "$(dirname "$to")"

  if [[ -L "$to" ]]; then
    run ln -sfn "$from" "$to"
    info "Updated symlink" path "$(basename "$to")"
  elif [[ -d "$to" ]]; then
    run mv "$to" "${to}.backup"
    warn "Backed up existing dir" path "$(basename "$to").backup"
    run ln -sfn "$from" "$to"
    info "Symlinked" path "$(basename "$to")"
  else
    run ln -sfn "$from" "$to"
    info "Symlinked" path "$(basename "$to")"
  fi
}

# Symlink each immediate subdirectory inside a parent dir.
# e.g. symlink_subdirs repo/.config ~/.config
#   → repo/.config/nvim  → ~/.config/nvim
#   → repo/.config/tmux  → ~/.config/tmux
symlink_subdirs() {
  local from="$1"
  local to="$2"

  [[ -d "$from" ]] || return 0
  run mkdir -p "$to"

  for dir in "$from"/*/; do
    [[ -d "$dir" ]] || continue
    symlink_dir "$dir" "$to/$(basename "$dir")"
  done
}

# Symlink individual scripts into ~/.local/scripts.
# Skips scripts that already exist as real files (machine-owned).
# Only adds scripts that are missing or already symlinks.
install_scripts() {
  local from="$1"
  local to="$2"

  [[ -d "$from" ]] || return 0
  run mkdir -p "$to"

  for script in "$from"/*; do
    [[ -f "$script" ]] || continue
    local name="$(basename "$script")"
    local target="$to/$name"

    if [[ -f "$target" && ! -L "$target" ]]; then
      skip "Skipped (machine-owned)" name "$name"
    else
      run ln -sf "$script" "$target"
      run chmod +x "$target"
      info "Installed script" name "$name"
    fi
  done
}

# Inject a source line at the top of ~/.zshrc without overwriting it.
# Safe to run multiple times — skips if marker is already present.
# On a fresh machine (no .zshrc) it creates one.
setup_zshrc() {
  local base="$ROOT_DIR/.zshrc"
  local target="$HOME/.zshrc"
  local marker="# config76:base"
  local source_line="source \"$base\"  $marker"

  [[ -f "$base" ]] || { warn "No base .zshrc in repo, skipping"; return; }

  if [[ ! -f "$target" ]]; then
    run bash -c "printf '%s\n' '$source_line' '' > '$target'"
    info "Created ~/.zshrc with source line"
  elif grep -qF "$marker" "$target"; then
    skip "~/.zshrc already has source line, skipping"
  else
    # Prepend to existing .zshrc — machine-specific content stays below
    local tmp
    tmp="$(mktemp)"
    printf '%s\n\n' "$source_line" > "$tmp"
    cat "$target" >> "$tmp"
    run mv "$tmp" "$target"
    info "Injected source line into ~/.zshrc"
    warn "Review ~/.zshrc — shared items now loaded via source, you can remove duplicates below"
  fi
}

# Symlink individual JSON files in .claude (settings.json etc).
# Skips mcp.json — that is handled separately by runs/claude.sh via merge.
setup_claude() {
  local from="$1"
  local to="$HOME/.claude"

  [[ -d "$from" ]] || return 0
  run mkdir -p "$to"

  for file in "$from"/*.json; do
    [[ -f "$file" ]] || continue
    local name="$(basename "$file")"

    # mcp.json is merged into ~/.claude.json by runs/claude.sh, skip here
    [[ "$name" == "mcp.json" ]] && continue

    local target="$to/$name"

    if [[ -f "$target" && ! -L "$target" ]]; then
      run mv "$target" "${target}.backup"
      warn "Backed up existing" name "$name"
    fi

    run ln -sf "$file" "$target"
    info "Symlinked" name "$name"
  done
}

# ─── Main ───────────────────────────────────────────────────────────────────

gum style \
  --foreground 212 --border-foreground 212 --border double \
  --align center --width 44 --margin "1 0" \
  "config76 — mac env"

[[ $DRY -eq 1 ]] && warn "Dry run — no changes will be made"

mkdir -p "$XDG_CONFIG_HOME"

section "Shared configs (nvim, tmux, ghostty...)"
symlink_subdirs "$ROOT_DIR/.config" "$XDG_CONFIG_HOME"

section "Shared scripts"
install_scripts "$ROOT_DIR/.local/scripts" "$HOME/.local/scripts"

section "Shell (.zshrc)"
setup_zshrc

section "Mac configs (yabai, skhd)"
symlink_subdirs "$SCRIPT_DIR/.config" "$XDG_CONFIG_HOME"

section "Claude settings"
setup_claude "$SCRIPT_DIR/.claude"
symlink_dir "$SCRIPT_DIR/.claude/skills" "$HOME/.claude/skills"

echo ""
gum style --foreground 82 --bold "  Done!"
