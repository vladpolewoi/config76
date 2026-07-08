# config76

Dotfiles and machine setup for macOS and Arch Linux.

## Structure

```
config76/
  .config/       Shared configs: nvim, tmux, ghostty
  .local/        Shared scripts
  claude/        Shared Claude Code config (mcp, settings, statusline, skills)
  .zshrc         Base shell config (sourced by machine ~/.zshrc)
  mac/           macOS-specific setup + overlays
  arch/          Arch Linux-specific setup + overlays
```

Config is **shared by default**. Platform dirs (`mac/`, `arch/`) hold only
OS-specific setup and thin overlays over the shared base.

## Setup

### macOS
```bash
cd mac
bash install.sh   # interactive — pick what to install
bash env.sh       # symlink dotfiles and configs
```

### Arch
```bash
cd arch
bash env.sh       # copy dotfiles and configs
```

---

## Two-way sync (`config-sync`)

`env.sh` **symlinks** the repo into place, so editing a tracked config edits the
repo directly. The `sync/` tools handle the rest: discovering *new* or *drifted*
configs, classifying them, and pushing.

```bash
config-sync            # or: config-sync status  — show what drifted (read-only)
config-sync pull       # repo → machine: git pull --rebase + re-run env.sh
config-sync push "msg" # machine → repo: stage + secrets-gate + rebase + push
```

`config-sync` is installed onto `PATH` by `env.sh` (symlinked into
`~/.local/scripts`) and works identically on Arch and macOS.

**Deciding where a new config belongs** (shared vs arch vs mac vs a package to
install) and **resolving conflicts** needs judgment — run the **`dotfiles-sync`
Claude Code skill**. It reads `config-sync status --json`, classifies each item,
writes a `plan.json`, and drives `sync/apply.sh` (dry-run first) then the push.

Under the hood (`sync/`):

| Script | Role | Side effects |
|---|---|---|
| `status.sh [--json]` | drift discovery | none |
| `apply.sh <plan> [--apply]` | execute a plan (adopt / resolve / install / ignore) | dry-run by default, secrets-gated |
| `pull.sh` / `push.sh` | git wrappers | yes |
| `ignore.txt` | noise/secret patterns `status.sh` skips | — |

Every write path runs a **secrets scan** before anything enters git.

---

## Required Secrets

Some configs depend on machine-specific values that are never committed.
Each platform has a `secrets.env.example` — copy it to `secrets.env` and fill in real values.
`secrets.env` is gitignored.

### arch/secrets.env

| Variable | Description |
|---|---|
| `DSD_CALENDAR_HOST` | Calendar server IP |
| `DSD_DEV_HOST` | Dev server IP |
| `CONSULT_ANTHROPIC_API_KEY` | Anthropic API key for the `consult` MCP server (`claude/mcp.json`) |
| `TG_MCP_ALLOWLIST` | Allowlist for the `telegram` MCP server (`claude/mcp.json`) |

```bash
cp arch/secrets.env.example arch/secrets.env
# edit with real values
```

## MCP servers

MCP servers are **shared** in `claude/mcp.json` and applied on both machines.
Each platform adds only OS-specific servers in its overlay
(`mac/.claude/mcp.json` = `XcodeBuildMCP`; `arch/.claude/mcp.json` = empty).
`claude/merge-mcp.py` (run by `env.sh` / `runs/claude.sh`) unions the shared
base + overlay into `~/.claude.json` — Claude Code reads servers from there, not
from `~/.claude/mcp.json`. The merge is additive: manually-added servers survive.

Secrets are **never hardcoded** — they reference environment variables
(e.g. `${CONSULT_ANTHROPIC_API_KEY}`, `${TG_MCP_ALLOWLIST}`), which Claude Code
expands from the shell that launched it. Local paths use `${HOME}` so the
committed config stays portable. Some servers also need a local checkout at
`~/code/…` — see [`claude/README.md`](claude/README.md) for the full
server/secret/prerequisite table.

So on a fresh machine the `consult` (or `telegram`) server will not start until
its key is present in the shell environment. Put the value in `arch/secrets.env`
(gitignored) and export it before launching `claude`, for example:

```bash
set -a; source arch/secrets.env; set +a   # export everything in the file
claude
```
