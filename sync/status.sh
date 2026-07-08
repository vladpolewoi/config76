#!/usr/bin/env bash
#
# status.sh — read-only drift discovery for config76.
#
# Compares the live machine against the repo and reports what has diverged,
# without touching anything. Two output modes:
#   (default)   human-readable, grouped sections
#   --json      machine-readable JSON for the dotfiles-sync skill / apply.sh
#
# Buckets:
#   repo_dirty       tracked/untracked changes already in the repo working tree
#                    (edits flowed back via whole-dir symlinks — ready to commit)
#   repo_ahead/behind  commits vs upstream (network only with --fetch)
#   symlink_broken   an expected symlink into the repo now dangles
#   symlink_replaced a symlink target was overwritten by a real file that
#                    differs from the repo version (app rewrote it — silent fork)
#   untracked        a live config with no repo counterpart (candidate to adopt),
#                    after filtering sync/ignore.txt
#
# Usage: sync/status.sh [--json] [--fetch]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
IGNORE_FILE="$SCRIPT_DIR/ignore.txt"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

case "$(uname -s)" in
  Darwin) PLATFORM="mac" ;;
  *)      PLATFORM="arch" ;;
esac

JSON=0
FETCH=0
for arg in "$@"; do
  case "$arg" in
    --json)  JSON=1 ;;
    --fetch) FETCH=1 ;;
  esac
done

# ─── Buckets (TAB-separated records: primary<TAB>detail) ────────────────────
declare -a REPO_DIRTY=()
declare -a SYMLINK_BROKEN=()
declare -a SYMLINK_REPLACED=()
declare -a UNTRACKED=()
REPO_AHEAD=0
REPO_BEHIND=0
UPSTREAM=""

# ─── Ignore matching ────────────────────────────────────────────────────────
declare -a IGNORE_PATTERNS=()
if [[ -f "$IGNORE_FILE" ]]; then
  while IFS= read -r line; do
    line="${line%%#*}"; line="${line// /}"
    [[ -n "$line" ]] && IGNORE_PATTERNS+=("$line")
  done < "$IGNORE_FILE"
fi

is_ignored() {
  local name="$1" pat
  for pat in "${IGNORE_PATTERNS[@]}"; do
    # shellcheck disable=SC2053
    [[ "$name" == $pat ]] && return 0
  done
  return 1
}

# ─── Repo working-tree state ────────────────────────────────────────────────
# Whole-dir symlinks mean edits to tracked configs already appear here.
scan_repo_state() {
  cd "$REPO"
  local line
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    local code="${line:0:2}" path="${line:3}"
    REPO_DIRTY+=("$path"$'\t'"$code")
  done < <(git status --porcelain 2>/dev/null)

  UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  [[ -n "$UPSTREAM" ]] || return 0
  [[ $FETCH -eq 1 ]] && git fetch --quiet 2>/dev/null || true
  local counts
  counts="$(git rev-list --left-right --count "${UPSTREAM}...HEAD" 2>/dev/null || echo "0	0")"
  REPO_BEHIND="$(awk '{print $1}' <<<"$counts")"
  REPO_AHEAD="$(awk '{print $2}' <<<"$counts")"
}

# ─── Live-vs-repo scan for one root ─────────────────────────────────────────
# scan_root <live_root> <mode:subdir|file> <repo_source_dir>...
# For each live entry: classify as tracked-ok / broken symlink / replaced /
# untracked candidate. Only reports problems and candidates.
scan_root() {
  local live_root="$1" mode="$2"; shift 2
  local -a sources=("$@")
  [[ -d "$live_root" ]] || return 0

  local entry name live
  for entry in "$live_root"/* "$live_root"/.[!.]*; do
    [[ -e "$entry" || -L "$entry" ]] || continue
    name="$(basename "$entry")"
    live="$entry"

    # Ignored names are runtime state / caches / secrets — skip entirely,
    # from every bucket (never a broken-link warning, never an adopt candidate).
    is_ignored "$name" && continue

    # In file mode, only look at files/symlinks; in subdir mode, only dirs.
    if [[ "$mode" == "file" ]]; then
      [[ -f "$live" || -L "$live" ]] || continue
    fi

    if [[ -L "$live" ]]; then
      local raw; raw="$(readlink "$live")"
      # Only care about symlinks that point back into our repo.
      case "$raw" in
        "$REPO"/*)
          if [[ ! -e "$live" ]]; then
            SYMLINK_BROKEN+=("$live"$'\t'"$raw")
          fi
          ;;
      esac
      continue
    fi

    # Real file/dir at a spot the repo might own → drift or new.
    local repo_match=""
    local src
    for src in "${sources[@]}"; do
      if [[ -e "$src/$name" ]]; then repo_match="$src/$name"; break; fi
    done

    if [[ -n "$repo_match" ]]; then
      # Repo owns a same-named entry but the live copy is a real file →
      # symlink was replaced or a machine-owned copy diverged.
      if ! diff -rq "$live" "$repo_match" >/dev/null 2>&1; then
        SYMLINK_REPLACED+=("$live"$'\t'"$repo_match")
      fi
    else
      UNTRACKED+=("$live"$'\t'"$PLATFORM")
    fi
  done
}

# ─── Run scans ──────────────────────────────────────────────────────────────
scan_repo_state
scan_root "$XDG_CONFIG_HOME"        subdir "$REPO/.config" "$REPO/$PLATFORM/.config"
scan_root "$HOME/.local/scripts"    file   "$REPO/.local/scripts" "$REPO/$PLATFORM/.local/scripts"
scan_root "$HOME/.claude"           file   "$REPO/$PLATFORM/.claude"
scan_root "$HOME/.claude/skills"    subdir "$REPO/claude/skills" "$REPO/$PLATFORM/.claude/skills"
scan_root "$HOME/.claude/commands"  file   "$REPO/$PLATFORM/.claude/commands"

# ─── Output ─────────────────────────────────────────────────────────────────
records_to_json() { # <array-name> → JSON array of {primary,detail}
  local -n arr="$1"
  if [[ ${#arr[@]} -eq 0 ]]; then echo "[]"; return; fi
  printf '%s\n' "${arr[@]}" | jq -R -s -c '
    split("\n") | map(select(length>0)) | map(split("\t")) |
    map({path: .[0], detail: (.[1] // "")})'
}

if [[ $JSON -eq 1 ]]; then
  jq -nc \
    --arg platform "$PLATFORM" \
    --arg upstream "$UPSTREAM" \
    --argjson behind "${REPO_BEHIND:-0}" \
    --argjson ahead "${REPO_AHEAD:-0}" \
    --argjson repo_dirty "$(records_to_json REPO_DIRTY)" \
    --argjson symlink_broken "$(records_to_json SYMLINK_BROKEN)" \
    --argjson symlink_replaced "$(records_to_json SYMLINK_REPLACED)" \
    --argjson untracked "$(records_to_json UNTRACKED)" \
    '{platform:$platform, repo:{upstream:$upstream, behind:$behind, ahead:$ahead},
      repo_dirty:$repo_dirty, symlink_broken:$symlink_broken,
      symlink_replaced:$symlink_replaced, untracked:$untracked}'
  exit 0
fi

# Pretty output
if command -v gum &>/dev/null; then
  hdr() { echo; gum style --foreground 99 --bold "$1"; }
  dim() { gum style --foreground 244 "  $1"; }
else
  hdr() { echo; echo "== $1 =="; }
  dim() { echo "  $1"; }
fi

echo "config76 status — platform: $PLATFORM"

hdr "Repo working tree"
if [[ ${#REPO_DIRTY[@]} -eq 0 ]]; then
  dim "clean"
else
  for rec in "${REPO_DIRTY[@]}"; do dim "${rec%%$'\t'*}  (${rec##*$'\t'})"; done
fi
[[ -n "$UPSTREAM" ]] && dim "upstream $UPSTREAM — behind $REPO_BEHIND, ahead $REPO_AHEAD"

hdr "Broken symlinks (dangling → repo)"
if [[ ${#SYMLINK_BROKEN[@]} -eq 0 ]]; then dim "none"; else
  for rec in "${SYMLINK_BROKEN[@]}"; do dim "${rec%%$'\t'*} -> ${rec##*$'\t'}"; done
fi

hdr "Replaced symlinks / diverged copies (silent fork)"
if [[ ${#SYMLINK_REPLACED[@]} -eq 0 ]]; then dim "none"; else
  for rec in "${SYMLINK_REPLACED[@]}"; do dim "${rec%%$'\t'*}  vs  ${rec##*$'\t'}"; done
fi

hdr "Untracked configs (adoption candidates)"
if [[ ${#UNTRACKED[@]} -eq 0 ]]; then dim "none"; else
  for rec in "${UNTRACKED[@]}"; do dim "${rec%%$'\t'*}"; done
fi
echo
