#!/usr/bin/env bash
#
# apply.sh — execute a sync plan produced by the dotfiles-sync skill.
#
# The skill does the JUDGMENT (classify shared/arch/mac, resolve conflicts) and
# writes a plan.json. This script does the MECHANICAL work, deterministically,
# so git and the filesystem are never touched by free-hand model commands.
#
# DRY-RUN BY DEFAULT. Pass --apply to actually mutate. A secrets scan is a hard
# gate before any file enters the repo.
#
# Plan format:
#   {"actions": [
#     {"op":"adopt",   "src":"~/.config/lazygit", "dest":".config/lazygit", "scope":"shared"},
#     {"op":"resolve", "path":".local/scripts/foo.sh", "resolution_file":"/tmp/m/foo.sh"},
#     {"op":"install", "pkg":"lazygit"},
#     {"op":"ignore",  "pattern":"warp-terminal"}
#   ]}
#
# Usage: sync/apply.sh <plan.json> [--apply] [--yes]
#        sync/apply.sh --apply < plan.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
IGNORE_FILE="$SCRIPT_DIR/ignore.txt"

case "$(uname -s)" in
  Darwin) PLATFORM="mac" ;;
  *)      PLATFORM="arch" ;;
esac

APPLY=0
ASSUME_YES=0
PLAN_FILE=""
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    *) PLAN_FILE="$arg" ;;
  esac
done

info() { echo "  [→] $*"; }
ok()   { echo "  [✓] $*"; }
warn() { echo "  [!] $*" >&2; }
die()  { echo "  [✗] $*" >&2; exit 1; }

do_or_echo() {
  if [[ $APPLY -eq 1 ]]; then "$@"; else echo "  dry: $*"; fi
}

confirm() {
  [[ $ASSUME_YES -eq 1 ]] && return 0
  [[ $APPLY -eq 0 ]] && return 0
  if command -v gum &>/dev/null; then gum confirm "$1"; else
    read -r -p "$1 [y/N] " a; [[ "$a" == "y" || "$a" == "Y" ]]
  fi
}

expand() { local p="$1"; echo "${p/#\~/$HOME}"; }

# ─── Secrets gate ───────────────────────────────────────────────────────────
# grep-based (gitleaks not assumed). Scans a file or dir. Returns non-zero and
# prints redacted hits if anything looks like a credential.
SECRET_RE='-----BEGIN [A-Z ]*PRIVATE KEY|(api[_-]?key|secret|token|password|passwd|bearer|client[_-]?secret)["'"'"' ]*[:=][ '"'"'"]*[A-Za-z0-9+/_-]{12,}|sk-[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{12,}|xox[baprs]-'
secrets_scan() {
  local target="$1" hits
  hits="$(grep -rIEn -e "$SECRET_RE" "$target" 2>/dev/null | head -20 || true)"
  if [[ -n "$hits" ]]; then
    warn "Possible secrets in $target:"
    # redact the value side, keep the key/location for triage
    sed -E 's/([:=]).*/\1 <redacted>/' <<<"$hits" | sed 's/^/      /' >&2
    return 1
  fi
  return 0
}

# ─── Ops ────────────────────────────────────────────────────────────────────
op_adopt() {
  local src dest scope
  src="$(expand "$(jq -r '.src' <<<"$1")")"
  dest="$(jq -r '.dest' <<<"$1")"
  scope="$(jq -r '.scope // "shared"' <<<"$1")"
  local repo_dest="$REPO/$dest"

  [[ -e "$src" ]] || { warn "adopt: src missing: $src"; return 1; }
  [[ -L "$src" ]] && { warn "adopt: src already a symlink, skipping: $src"; return 0; }
  [[ -e "$repo_dest" ]] && { warn "adopt: dest exists in repo: $dest — use resolve"; return 1; }

  if ! secrets_scan "$src"; then
    confirm "adopt $src ANYWAY (secrets suspected)?" || { warn "skipped $src"; return 1; }
  fi

  info "adopt [$scope] $src -> $dest (+ symlink back)"
  confirm "adopt $dest?" || { warn "skipped"; return 0; }
  do_or_echo mkdir -p "$(dirname "$repo_dest")"
  do_or_echo mv "$src" "$repo_dest"
  do_or_echo ln -sfn "$repo_dest" "$src"
  if [[ $APPLY -eq 1 ]]; then
    [[ -L "$src" && -e "$src" ]] && ok "adopted + linked $dest" || die "symlink verify failed: $src"
  fi
}

op_resolve() {
  local path res
  path="$(jq -r '.path' <<<"$1")"
  res="$(expand "$(jq -r '.resolution_file' <<<"$1")")"
  local repo_dest="$REPO/$path"

  [[ -f "$res" ]] || { warn "resolve: resolution_file missing: $res"; return 1; }
  if ! secrets_scan "$res"; then
    confirm "resolve $path ANYWAY (secrets suspected)?" || { warn "skipped"; return 1; }
  fi
  info "resolve $path  <=  $res"
  confirm "write resolved $path into repo?" || { warn "skipped"; return 0; }
  do_or_echo mkdir -p "$(dirname "$repo_dest")"
  do_or_echo cp "$res" "$repo_dest"
  ok "resolved $path"
}

op_install() {
  local pkg
  pkg="$(jq -r '.pkg' <<<"$1")"
  [[ -n "$pkg" && "$pkg" != "null" ]] || { warn "install: no pkg"; return 1; }

  if [[ "$PLATFORM" == "arch" ]]; then
    local runscript="$REPO/arch/runs/${pkg}.sh"
    if [[ -e "$runscript" ]]; then ok "install: arch/runs/${pkg}.sh already exists"; return 0; fi
    info "install: create arch/runs/${pkg}.sh"
    confirm "create arch/runs/${pkg}.sh?" || return 0
    if [[ $APPLY -eq 1 ]]; then
      cat > "$runscript" <<EOF
#!/usr/bin/env bash
# ${pkg} — added by sync/apply.sh, review before running.
set -e
if ! pacman -Qi ${pkg} &>/dev/null && ! command -v ${pkg} &>/dev/null; then
  sudo pacman -S --needed --noconfirm ${pkg} || yay -S --needed --noconfirm ${pkg}
fi
EOF
      chmod +x "$runscript"; ok "created arch/runs/${pkg}.sh"
    else echo "  dry: write arch/runs/${pkg}.sh"; fi
  else
    local brewfile="$REPO/mac/Brewfile"
    if grep -qE "^brew \"${pkg}\"|^cask \"${pkg}\"" "$brewfile" 2>/dev/null; then
      ok "install: ${pkg} already in Brewfile"; return 0; fi
    info "install: add 'brew \"${pkg}\"' to mac/Brewfile"
    confirm "append ${pkg} to Brewfile?" || return 0
    do_or_echo bash -c "printf 'brew \"%s\"\n' '${pkg}' >> '${brewfile}'"
    ok "added ${pkg} to Brewfile"
  fi
}

op_ignore() {
  local pat
  pat="$(jq -r '.pattern' <<<"$1")"
  [[ -n "$pat" && "$pat" != "null" ]] || return 1
  grep -qxF "$pat" "$IGNORE_FILE" 2>/dev/null && { ok "ignore: '$pat' already present"; return 0; }
  info "ignore: add '$pat' to sync/ignore.txt"
  do_or_echo bash -c "printf '%s\n' '$pat' >> '$IGNORE_FILE'"
}

# ─── Drive ──────────────────────────────────────────────────────────────────
PLAN="$( [[ -n "$PLAN_FILE" ]] && cat "$PLAN_FILE" || cat )"
echo "$PLAN" | jq -e '.actions' >/dev/null 2>&1 || die "invalid plan: no .actions array"

[[ $APPLY -eq 0 ]] && warn "DRY RUN — pass --apply to make changes"
echo "Platform: $PLATFORM   Actions: $(jq '.actions|length' <<<"$PLAN")"
echo

while IFS= read -r action; do
  op="$(jq -r '.op' <<<"$action")"
  case "$op" in
    adopt)   op_adopt   "$action" || true ;;
    resolve) op_resolve "$action" || true ;;
    install) op_install "$action" || true ;;
    ignore)  op_ignore  "$action" || true ;;
    *) warn "unknown op: $op" ;;
  esac
done < <(jq -c '.actions[]' <<<"$PLAN")

echo
[[ $APPLY -eq 1 ]] && ok "Plan applied. Review 'git status' then run sync/push.sh." \
                   || info "Dry run complete. Re-run with --apply to execute."
