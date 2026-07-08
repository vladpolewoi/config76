#!/bin/bash

set -e

header() { echo "==== $1 ===="; }; success() { echo "  ✓ $1"; }; skip() { echo "  - SKIP: $1"; }; info() { echo "  $1"; }; warn() { echo "WARN: $1"; }

header "Claude Code — MCP servers"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAC_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$MAC_ROOT/.." && pwd)"

SHARED_MCP="$REPO_ROOT/claude/mcp.json"
OVERLAY_MCP="$MAC_ROOT/.claude/mcp.json"
MERGE="$REPO_ROOT/claude/merge-mcp.py"

# Claude Code reads mcpServers from ~/.claude.json (NOT ~/.claude/mcp.json).
# merge-mcp.py unions the shared base + this platform's overlay into that file,
# preserving any servers already present. Settings and the statusline are linked
# by env.sh (setup_claude); this script only touches MCP so a plain `claude`
# launch after `git pull` still picks up new servers.
if [ -f "$MERGE" ] && [ -f "$SHARED_MCP" ]; then
  result=$(python3 "$MERGE" "$SHARED_MCP" "$OVERLAY_MCP")
  if [ "$result" = "SKIP" ]; then
    skip "MCP servers (unchanged)"
  else
    success "MCP servers merged into ~/.claude.json"
  fi
  info "Servers: $(python3 -c "import json,sys; ks=set(); [ks.update(json.load(open(p)).get('mcpServers',{})) for p in sys.argv[1:] if __import__('os').path.exists(p)]; print(', '.join(sorted(ks)))" "$SHARED_MCP" "$OVERLAY_MCP")"
else
  skip "No shared mcp.json / merge-mcp.py found under $REPO_ROOT/claude"
fi

success "Claude Code MCP config complete"
