# Shared Claude Code config

Everything an agent needs to know about how Claude Code is configured on both
machines. **The whole config is shared by default** — only genuinely
OS-specific bits live in a platform overlay.

## Layout

```
claude/                     ← SHARED base (applied on Arch AND macOS)
  mcp.json                  MCP servers (cross-platform)
  settings.json             permissions, model, hooks, plugins, env…
  merge-mcp.py              merges mcp servers into ~/.claude.json
  skills/                   shared skill library
  mods/                     Claude Code mods (function-hook plugins), see below

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
   (`settings.json`, and mac's `settings.local.json`). Directories such as
   `mods/` are not linked; settings point at them in place.
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

Servers that reference `${VAR}` need that var in the environment when `claude`
starts. Put values in `<platform>/secrets.env` (gitignored); the shared `.zshrc`
auto-sources it on shell init, so a `claude` launched from a normal terminal
already has them. If you launch from a shell that never sourced it, export first:

```bash
set -a; source mac/secrets.env; set +a   # or arch/secrets.env
claude
```

| Server | Needs |
|---|---|
| `consult` | `${CONSULT_ANTHROPIC_API_KEY}` (or user-level `~/.consult-mcp/.env`, which wins) + built `consult-mcp` (`.venv`) |
| `telegram` | `${TG_MCP_ALLOWLIST}` = **path** to a JSON allowlist file (`{"chats":[…]}`) + one-time `uv run tg-mcp-auth` (keyring) |
| `projects` | `projects-mcp/.env` (copy `.env.example`) + built `projects-mcp` (`dist/`) |

The code for these three lives in the **private** [`mcp-servers`](https://github.com/vladpolewoi/mcp-servers)
repo (not in this public repo — it only holds the config pointer). On a fresh
machine:

```bash
gh repo clone vladpolewoi/mcp-servers ~/code/mcp-servers
cd ~/code/mcp-servers
(cd consult-mcp && uv sync)
(cd projects-mcp && npm install && npm run build)
(cd telegram-mcp && uv sync && uv run tg-mcp-auth)   # one-time Telegram login
```

`claude/mcp.json` points at `${HOME}/code/mcp-servers/<server>/…`. If a server
won't start, check (1) its secret env var is exported from `secrets.env` and
(2) it's cloned + built at that path. See the repo's `README.md` + per-dir
`SETUP.md`.

## Adding a server

1. Cross-platform → add it to `claude/mcp.json`. OS-only → the platform overlay.
2. Use `${HOME}/...` for any local path; use `${SOME_SECRET}` for secrets and
   add the var to `secrets.env.example` (both platforms) — never commit a value.
3. Re-run `bash env.sh` (or `config-sync pull`) to merge it into `~/.claude.json`.

## Mods (`mods/`)

Mods are plugins of function hooks that run inside Claude Code. Each one is a
folder loaded straight from this repo through `CLAUDE_CODE_PLUGIN_DIRS` in the
`env` block of `settings.json` (`~` allowed, `:`-separated for several), so a
`git pull` is the whole update; edits reload live in a running session.

- `mods/token-ledger/` — replaces the old statusline. A box above the prompt with
  the context fill against a lean/limit budget (150k/300k, set in `/config`), a
  bar by category, the 5h and weekly usage with reset times and the session $;
  a card beside it with model, effort, repo and branch; a cost line under each
  answer; and `/tokens [today|7d|30d]`, a pane of where the tokens went by
  project, task, model and agent (ledger files in `~/.claude/token-ledger/`).
  Check it with `claude plugin validate` and `claude plugin test` on the folder.

