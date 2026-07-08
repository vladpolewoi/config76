#!/usr/bin/env bash
#
# push.sh — machine → repo. Stage, secrets-gate, commit, rebase on top of
# origin, push. Ordering per design: commit local first, THEN pull --rebase,
# THEN push — so a concurrent machine's work is never clobbered.
#
# Usage: sync/push.sh ["commit message"] [--yes]
#        (no message → opens $EDITOR via git commit)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"

MSG=""
ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    --yes|-y) ASSUME_YES=1 ;;
    *) MSG="$arg" ;;
  esac
done

info() { echo "  [→] $*"; }
ok()   { echo "  [✓] $*"; }
warn() { echo "  [!] $*" >&2; }
die()  { echo "  [✗] $*" >&2; exit 1; }
confirm() {
  [[ $ASSUME_YES -eq 1 ]] && return 0
  if command -v gum &>/dev/null; then gum confirm "$1"; else
    read -r -p "$1 [y/N] " a; [[ "$a" == "y" || "$a" == "Y" ]]
  fi
}

cd "$REPO"

if [[ -z "$(git status --porcelain)" ]] && git rev-parse '@{u}' &>/dev/null \
   && [[ "$(git rev-list --count '@{u}'..HEAD)" -eq 0 ]]; then
  ok "Nothing to commit or push."; exit 0
fi

echo "── changes ──"; git status --short; echo

# Stage everything, then run a final secrets scan over the staged diff.
info "Staging all changes…"
git add -A

SECRET_RE='-----BEGIN [A-Z ]*PRIVATE KEY|(api[_-]?key|secret|token|password|passwd|bearer|client[_-]?secret)["'"'"' ]*[:=][ '"'"'"]*[A-Za-z0-9+/_-]{12,}|sk-[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{12,}|xox[baprs]-'
if git diff --cached | grep -IE -e "$SECRET_RE" >/dev/null 2>&1; then
  warn "Staged diff matches secret patterns. Offending files:"
  git diff --cached --name-only | while read -r f; do
    grep -IEl -e "$SECRET_RE" "$f" 2>/dev/null && echo "      ^ $f" >&2
  done
  git reset -q
  die "Unstaged everything. Move secrets to secrets.env (env-var refs) and retry."
fi
ok "Secrets scan clean."

if [[ -z "$(git diff --cached --name-only)" ]]; then
  info "No file changes staged; will just rebase & push existing commits."
else
  confirm "Commit these changes?" || { git reset -q; die "Aborted; unstaged."; }
  if [[ -n "$MSG" ]]; then git commit -q -m "$MSG"; else git commit; fi
  ok "Committed."
fi

if git rev-parse '@{u}' &>/dev/null; then
  info "Rebasing onto upstream…"
  git pull --rebase --autostash || die "Rebase conflict — resolve, then rerun push."
fi

confirm "Push to $(git rev-parse --abbrev-ref '@{u}' 2>/dev/null || echo origin)?" || { warn "Not pushed."; exit 0; }
git push
ok "Pushed."
