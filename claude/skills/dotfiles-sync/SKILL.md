---
name: dotfiles-sync
description: Sync this machine with the config76 dotfiles repo — pull latest, discover configs that drifted or are newly created, classify each as shared / arch / mac / package-install, resolve conflicts, then commit & push. Use when the user says "sync my config", "sync dotfiles", "sync configs", "pull my setup", "push my config changes", "config76 sync", or wants to reconcile their Arch PC and MacBook environments.
---

# dotfiles-sync

Two-way sync between the live machine and the `config76` repo. The goal: a new
computer clones the repo, runs one installer, and the whole environment appears
— and edits made on either the Arch PC or the MacBook flow back so nothing gets
recreated twice (especially Claude settings + skills).

## Division of labour — READ THIS FIRST

The mechanical work is done by **deterministic scripts** in `sync/`. Your job is
only the **judgment**: classify where a new config belongs and mediate conflicts.
**Never** run raw `git add/commit/push/mv/ln` yourself — always go through the
scripts. They are idempotent, secrets-gated, and dry-run by default.

| Script | What it does | Side effects |
|---|---|---|
| `sync/status.sh [--json]` | report drift | none (read-only) |
| `sync/apply.sh <plan> [--apply]` | execute a plan you write | dry-run unless `--apply` |
| `sync/pull.sh` | `git pull --rebase` + run `env.sh` (symlink everything) | yes |
| `sync/push.sh ["msg"]` | stage + secrets-gate + rebase + push | yes |
| `config-sync <cmd>` | PATH wrapper for all of the above | — |

## Workflow

### 1. Read the state
Run `sync/status.sh --json`. Buckets:
- **repo_dirty** — edits already in the repo working tree (whole-dir symlinks
  mean live edits land here automatically). These just need committing.
- **repo behind/ahead** — commits vs upstream.
- **symlink_broken** — a symlink into the repo now dangles (usually the repo
  file was renamed/removed, or `env.sh` never ran). Re-running `pull.sh` fixes most.
- **symlink_replaced** — an app overwrote a symlink with a real file that differs
  from the repo → a *silent fork*. Conflict; mediate (step 4).
- **untracked** — a live config with no repo counterpart. Classify (step 3).

### 2. Decide direction
- Behind and clean → `sync/pull.sh`, done.
- Only repo_dirty (tracked edits) → go straight to step 5 (push).
- Untracked / replaced present → classify & build a plan (steps 3–4).

### 3. Classify each untracked config → a plan action
**Read the file(s)** before deciding. Heuristics:
- **arch** — hyprland, waybar, wofi, swaync, kitty, pacman/yay, anything
  Wayland/X11 or Linux-only. → `dest: "arch/.config/<name>"`, `scope: "arch"`.
- **mac** — yabai, skhd, aerospace, `defaults write`, Homebrew casks, anything
  macOS-only. → `dest: "mac/.config/<name>"`, `scope: "mac"`.
- **shared** — nvim, tmux, ghostty, git, lazygit, ranger, starship: exists and
  behaves the same on both OSes. → `dest: ".config/<name>"`, `scope: "shared"`.
  Claude skills go to `claude/skills/<name>` (shared) or `<platform>/.claude/skills/<name>`.
- **package-install** — the config implies a tool that isn't installed by the
  repo yet → also add an `install` action (`arch/runs/<pkg>.sh` or `mac/Brewfile`).
- **ignore** — runtime state / cache / app profile / secret → `ignore` action
  (appends to `sync/ignore.txt` so it stops showing up).

Watch for **machine-specific values inside otherwise-shared configs** (monitor
names, `/home` vs `/Users`, hardware IDs, absolute paths). Don't blindly share —
either classify platform-only or flag it to the user and split into a shared base
+ platform override. When unsure, **ask** rather than guess.

### 4. Resolve conflicts (symlink_replaced / rebase conflicts)
For each conflict: diff the live file vs the repo file. Use mtime, `git log -1`
dates, and *what the change actually is* to decide the winner — or merge both by
function. Write the merged result to a temp file (e.g.
`$SCRATCH/merge/<name>`) and emit a `resolve` action pointing `path` at the repo
file and `resolution_file` at your merged temp file. Show the user your rationale
before applying. For a git rebase conflict during pull/push, resolve the files,
then tell the user to `git rebase --continue` (or do it via a plain edit — never
improvise git history rewrites).

### 5. Build and run the plan
Write `plan.json` (schema below) to the scratchpad. Then:
1. `sync/apply.sh <plan.json>` — **dry run**. Show the user what it would do.
2. On approval: `sync/apply.sh <plan.json> --apply`.
3. `sync/push.sh "<conventional commit message>"` — this stages, runs the
   secrets gate again, rebases onto origin, and pushes (each step confirmable).

Always let the user approve before the `--apply` and before the push.

## Plan schema

```json
{"actions": [
  {"op":"adopt",   "src":"~/.config/lazygit", "dest":".config/lazygit", "scope":"shared"},
  {"op":"adopt",   "src":"~/.config/hypr/hypridle.conf", "dest":"arch/.config/hypr/hypridle.conf", "scope":"arch"},
  {"op":"resolve", "path":".local/scripts/launch-project.sh", "resolution_file":"/…/merge/launch-project.sh"},
  {"op":"install", "pkg":"lazygit"},
  {"op":"ignore",  "pattern":"warp-terminal"}
]}
```
- **adopt** — move a live file/dir into the repo at `dest`, then symlink it back
  so it stays live *and* tracked (exactly what `env.sh` would have produced).
- **resolve** — copy your merged `resolution_file` over the repo `path`.
- **install** — ensure a package is captured (arch: creates `arch/runs/<pkg>.sh`;
  mac: appends to `Brewfile`). Additive, idempotent.
- **ignore** — append a pattern to `sync/ignore.txt`.

## Safety rules
- Deterministic scripts do all git/fs mutation. You only read status and write a plan.
- Everything is dry-run first; the user approves `--apply` and the push separately.
- The secrets gate (in `apply.sh` and `push.sh`) blocks credentials. If it fires,
  propose moving the value into `secrets.env` and referencing it via an env var —
  do not adopt the raw file.
- `mcp.json`, rendered SSH config, and Claude runtime/cache files are intentionally
  not synced — they're in `sync/ignore.txt`. Leave them alone.

## Fresh machine (no repo yet)
That's `bootstrap.sh` (clone + install), not this skill. After it runs once,
`config-sync pull` keeps the machine current and this skill handles capture.
