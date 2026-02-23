#!/bin/bash

set -e

# Source style helpers (fallback to plain echo)
_style_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" 2>/dev/null && pwd)"
[[ -f "$_style_dir/style.sh" ]] && source "$_style_dir/style.sh"
type header &>/dev/null || { header() { echo "==== $1 ===="; }; success() { echo "  ✓ $1"; }; skip() { echo "  - SKIP: $1"; }; info() { echo "  $1"; }; step() { echo ">> $1"; }; warn() { echo "WARN: $1"; }; }

header "Claude Code"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAC_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$MAC_ROOT/.claude"
CLAUDE_JSON="$HOME/.claude.json"

# --- MCP servers ---
# Claude Code reads mcpServers from ~/.claude.json (NOT ~/.claude/mcp.json).
# Merge our MCP config into the top-level "mcpServers" key.
MCP_SOURCE="$SOURCE_DIR/mcp.json"
if [ -f "$MCP_SOURCE" ]; then
  [ -f "$CLAUDE_JSON" ] || echo '{}' > "$CLAUDE_JSON"

  # Resolve bare command names to full paths, then merge into ~/.claude.json
  result=$(python3 -c "
import json, shutil

with open('$MCP_SOURCE') as f:
    mcp = json.load(f)
with open('$CLAUDE_JSON') as f:
    claude = json.load(f)

servers = mcp.get('mcpServers', {})
for cfg in servers.values():
    cmd = cfg.get('command', '')
    if '/' not in cmd:
        full = shutil.which(cmd)
        if full:
            cfg['command'] = full

old = json.dumps(claude.get('mcpServers', {}), sort_keys=True)
new = json.dumps(servers, sort_keys=True)

if old == new:
    print('SKIP')
else:
    claude['mcpServers'] = servers
    with open('$CLAUDE_JSON', 'w') as f:
        json.dump(claude, f, indent=2)
    print('UPDATED')
")

  if [ "$result" = "SKIP" ]; then
    skip "MCP servers (unchanged)"
  else
    success "MCP servers merged into ~/.claude.json"
    info "Servers: $(python3 -c "import json; d=json.load(open('$MCP_SOURCE')); print(', '.join(d.get('mcpServers',{}).keys()))")"
  fi
else
  skip "No mcp.json found in $SOURCE_DIR"
fi

# --- Other config files (settings.json, etc.) ---
TARGET_DIR="$HOME/.claude"
mkdir -p "$TARGET_DIR"

for file in "$SOURCE_DIR"/*.json; do
  [ -f "$file" ] || continue
  name=$(basename "$file")

  # Skip mcp.json — handled above via ~/.claude.json merge
  [ "$name" = "mcp.json" ] && continue

  target="$TARGET_DIR/$name"

  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    if cmp -s "$file" "$target"; then
      skip "~/.claude/$name (unchanged)"
      continue
    fi
    mv "$target" "$target.backup"
    warn "Backed up: $target -> $target.backup"
  fi

  cp "$file" "$target"
  success "Copied ~/.claude/$name"
  info "$file -> $target"
done

success "Claude Code config complete"
