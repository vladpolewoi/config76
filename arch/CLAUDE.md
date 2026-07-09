# Global Claude Config

## Task Management

Dev tasks are tracked in Obsidian vault:
- **Vault path**: `/home/user76/vault76/`
- **Task board**: `/home/user76/vault76/2026/Dev Tasks.md` (Kanban format)

When user asks to:
- "Add task" / "Add to backlog" → Add to Backlog column
- "What's on my tasks?" → Read the task board
- "Move X to done" → Move task to Done column
- "Start working on X" → Move to In Progress

**Token Protection Strategy**:
- Before spawning 3+ parallel agents → **Ask for confirmation**

## Commands

Custom commands are in `.claude/commands/`:
- `/task` - Structured development workflow

## MCP servers & secrets

Servers are **shared** in the repo-root `claude/mcp.json` and applied on every
machine; `arch/.claude/mcp.json` is just an (empty) Arch overlay. See
[`../claude/README.md`](../claude/README.md) for the full layout, merge, and
server/prerequisite table. **Never hardcode secrets** — this repo is public;
secrets are `${VAR}` refs expanded by Claude Code from the launching shell.

- `consult` reads `${CONSULT_ANTHROPIC_API_KEY}` (an `sk-ant-...` key; also falls
  back to a user-level `~/.consult-mcp/.env`, which wins over an empty/unexpanded
  var); `telegram` reads `${TG_MCP_ALLOWLIST}` — the **path** to a JSON allowlist
  file, not the ids themselves. Provide values via `secrets.env` (gitignored,
  templated by `secrets.env.example`); the shared `.zshrc` auto-sources it on
  shell init, so `claude` from a normal terminal already has them. Manual export
  only if launching from a shell that never sourced it:
  `set -a; source arch/secrets.env; set +a`.

On a fresh machine, if an MCP server fails to start, check (1) its required
secret env var is exported and (2) its code is built. `consult`, `projects`,
`telegram` live in the private `mcp-servers` repo — clone to
`~/code/mcp-servers` and build per each dir's `SETUP.md` (see `../claude/README.md`).
