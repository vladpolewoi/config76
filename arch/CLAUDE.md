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

Servers are declared in `.claude/mcp.json`. **Never hardcode secrets there** —
this repo is public. Secrets are referenced as env vars and expanded by Claude
Code from the launching shell's environment.

- `consult` reads `${CONSULT_ANTHROPIC_API_KEY}` (an `sk-ant-...` key). It will
  not start until that var is set. Provide it via `secrets.env` (gitignored,
  templated by `secrets.env.example`) and export it before running `claude`:
  `set -a; source arch/secrets.env; set +a`.

On a fresh machine, if an MCP server fails to start, first check whether its
required secret env var is present in the environment.
