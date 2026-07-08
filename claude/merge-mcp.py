#!/usr/bin/env python3
"""Merge shared + platform MCP servers into ~/.claude.json (additive union).

Usage:
    merge-mcp.py <shared-mcp.json> [<overlay-mcp.json> ...]

Claude Code reads MCP servers from ~/.claude.json (NOT ~/.claude/mcp.json), so
every machine has to have the repo's servers merged into that file. This script
does it the same way on Arch and macOS:

  * Reads "mcpServers" from each source in order; a later source overrides a
    same-named server from an earlier one (shared first, platform overlay last).
  * Expands ${HOME} in commands/args/env values to the current home dir, so the
    committed configs stay portable (no /home/<user> or /Users/<user> literals).
    Any OTHER ${VAR} (e.g. ${CONSULT_ANTHROPIC_API_KEY}, ${TG_MCP_ALLOWLIST}) is
    left intact for Claude Code to expand from the launching shell's environment
    — that is how secrets stay out of git.
  * Resolves bare command names (no "/") to absolute paths via $PATH.
  * Unions the result into ~/.claude.json's top-level "mcpServers", PRESERVING
    any servers already there that this repo does not manage. Project-scoped
    servers (projects.<path>.mcpServers) are never touched.

Prints SKIP if nothing changed, UPDATED otherwise. Exit status is always 0 on a
successful run so callers can treat "no change" as success.
"""
import json
import os
import shutil
import sys

HOME = os.path.expanduser("~")


def load(path):
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        return {}


def expand_home(value):
    """Expand only the literal ${HOME} token; leave all other ${VAR} refs."""
    if isinstance(value, str):
        return value.replace("${HOME}", HOME)
    if isinstance(value, list):
        return [expand_home(v) for v in value]
    if isinstance(value, dict):
        return {k: expand_home(v) for k, v in value.items()}
    return value


def main(argv):
    sources = argv[1:]
    if not sources:
        sys.exit("usage: merge-mcp.py <mcp.json> [overlay.json ...]")

    managed = {}
    for src in sources:
        for name, cfg in load(src).get("mcpServers", {}).items():
            managed[name] = expand_home(cfg)

    # Resolve bare command names to absolute paths (skip ${VAR}/path commands).
    for cfg in managed.values():
        cmd = cfg.get("command", "")
        if cmd and "/" not in cmd and "$" not in cmd:
            full = shutil.which(cmd)
            if full:
                cfg["command"] = full

    claude_json = os.path.join(HOME, ".claude.json")
    if not os.path.exists(claude_json):
        with open(claude_json, "w") as f:
            f.write("{}")
    claude = load(claude_json)

    existing = claude.get("mcpServers", {})
    before = json.dumps(existing, sort_keys=True)
    merged = {**existing, **managed}  # additive union; repo wins on conflict
    after = json.dumps(merged, sort_keys=True)

    if before == after:
        print("SKIP")
        return

    claude["mcpServers"] = merged
    with open(claude_json, "w") as f:
        json.dump(claude, f, indent=2)
    print("UPDATED")


if __name__ == "__main__":
    main(sys.argv)
