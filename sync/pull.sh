#!/usr/bin/env bash
#
# pull.sh — repo → machine. Pull latest, then install/symlink via env.sh.
# Safe to run anytime; uses --autostash so local edits survive the rebase.
# Stops loudly on rebase conflict so the dotfiles-sync skill can mediate.
#
# Usage: sync/pull.sh [--dry]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
case "$(uname -s)" in Darwin) PLATFORM="mac" ;; *) PLATFORM="arch" ;; esac
DRY=""; [[ "${1:-}" == "--dry" ]] && DRY="--dry"

info() { echo "  [→] $*"; }
ok()   { echo "  [✓] $*"; }
die()  { echo "  [✗] $*" >&2; exit 1; }

cd "$REPO"
info "Pulling origin (rebase, autostash)…"
if ! git pull --rebase --autostash; then
  die "Rebase hit conflicts. Resolve, then 'git rebase --continue' (or ask the dotfiles-sync skill)."
fi
ok "Repo up to date."

ENV="$REPO/$PLATFORM/env.sh"
[[ -x "$ENV" ]] || die "no $ENV"
info "Installing/symlinking via $PLATFORM/env.sh $DRY…"
bash "$ENV" $DRY
ok "Machine synced from repo."
