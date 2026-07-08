# Shared Claude Code config

Everything an agent needs to know about how Claude Code is configured on both
machines. **The whole config is shared by default** — only genuinely
OS-specific bits live in a platform overlay.

## Layout

```
claude/                     ← SHARED base (applied on Arch AND macOS)
  mcp.json                  MCP servers (cross-platform)
  settings.json             permissions, model, hooks, plugins, statusline…
  statusline-command.sh     statusline renderer (referenced by settings.json)
  merge-mcp.py              merges mcp servers into ~/.claude.json
  skills/                   shared skill library

arch/.claude/               ← Arch overlay (usually empty)
  mcp.json                  { "mcpServers": {} }

mac/.claude/                ← macOS overlay
  mcp.json                  { XcodeBuildMCP }   (needs xcodebuild → mac only)
  settings.local.json       { "effortLevel": "medium" }  (overrides base)
```

**Rule of thumb: add to the shared base.** Put something in a platform overlay
only if it cannot work on the other OS (e.g. `XcodeBuildMCP`) or is a deliberate
per-machine override (e.g. mac's lower `effortLevel`).

## How it's applied

`env.sh` (`setup_claude`) on each machine:

1. Symlinks shared `claude/*` then the platform overlay into `~/.claude/`
   (`settings.json`, `statusline-command.sh`, and mac's `settings.local.json`).
   Claude Code deep-merges `settings.local.json` over `settings.json`.
2. Runs `merge-mcp.py claude/mcp.json <platform>/.claude/mcp.json` to union the
   MCP servers into `~/.claude.json` (see below). `runs/claude.sh` re-runs this
   on macOS so a plain `claude` after `git pull` also stays current.

`mcp.json` is **never** symlinked — Claude Code reads servers from
`~/.claude.json`, not `~/.claude/mcp.json`.

## MCP merge (`merge-mcp.py`)

- **Additive union**: shared + overlay are merged INTO the existing
  `~/.claude.json` `mcpServers`. Servers you added by hand are preserved;
  project-scoped servers (`projects.<path>.mcpServers`) are untouched.
- **`${HOME}` is expanded** at merge time so committed configs stay portable
  (no `/home/<user>` or `/Users/<user>` literals in git).
- **All other `${VAR}` refs are left intact** for Claude Code to expand from the
  launching shell — this is how secrets stay out of git.
- Bare command names (`node`, `uv`, `npx`) are resolved to absolute paths.

## Secrets & prerequisites

Servers that reference `${VAR}` need that var exported before `claude` starts.
Put values in `<platform>/secrets.env` (gitignored) and export them:

```bash
set -a; source arch/secrets.env; set +a   # or mac/secrets.env
claude
```

| Server | Needs |
|---|---|
| `consult` | `${CONSULT_ANTHROPIC_API_KEY}` + checkout at `~/code/consult-mcp` (`.venv`) |
| `telegram` | `${TG_MCP_ALLOWLIST}` + checkout at `~/code/telegram-mcp` (run via `uv`) |
| `projects` | checkout at `~/code/projects-mcp` (built → `dist/index.js`) |
| `p7-projects` | server at `~/.claude/mcp-servers/p7-projects/server.mjs` |

Local-checkout servers only start on a machine where that repo exists at the
path above. If an MCP server won't start on a fresh machine, check (1) its
secret env var is exported and (2) its checkout/build exists.

## Adding a server

1. Cross-platform → add it to `claude/mcp.json`. OS-only → the platform overlay.
2. Use `${HOME}/...` for any local path; use `${SOME_SECRET}` for secrets and
   add the var to `secrets.env.example` (both platforms) — never commit a value.
3. Re-run `bash env.sh` (or `config-sync pull`) to merge it into `~/.claude.json`.
