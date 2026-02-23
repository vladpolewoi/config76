#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors ──
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# ── Ensure gum is installed ──
if ! command -v gum &>/dev/null; then
  echo -e "${YELLOW}gum not found. Installing...${RESET}"
  brew install gum
fi

# ── Collect available scripts ──
LABELS=()
PATHS=()

collect_scripts() {
  local dir="$1"

  [[ -d "$dir" ]] || return

  while IFS= read -r script; do
    [[ -f "$script" ]] || continue
    local name
    name="$(basename "$script" .sh)"
    LABELS+=("$name")
    PATHS+=("$script")
  done < <(find "$dir" -maxdepth 1 -type f \( -name '*.sh' -o ! -name '*.*' \) | sort)
}

collect_scripts "$SCRIPT_DIR/runs"

if [[ ${#LABELS[@]} -eq 0 ]]; then
  echo -e "${RED}No scripts found.${RESET}"
  exit 1
fi

# ── Header ──
gum style \
  --border rounded \
  --border-foreground 6 \
  --padding "1 3" \
  --margin "1 0" \
  --bold \
  "config76 mac installer" \
  "" \
  "Scripts: ${#LABELS[@]} available"

# ── Mode selection ──
MODE=$(gum choose \
  "Select scripts to install" \
  "Install ALL scripts" \
  --header "What do you want to do?")

# Find path by label
path_for() {
  local target="$1"
  for i in "${!LABELS[@]}"; do
    if [[ "${LABELS[$i]}" == "$target" ]]; then
      echo "${PATHS[$i]}"
      return
    fi
  done
}

run_script() {
  local label="$1"
  local script
  script="$(path_for "$label")"

  echo ""
  gum style --foreground 6 --bold ">> $label"

  if bash "$script"; then
    gum style --foreground 2 "   done"
  else
    gum style --foreground 1 "   failed (exit $?)"
  fi
}

case "$MODE" in
  "Select scripts to install")
    SELECTED=$(gum choose --no-limit --header "Select scripts to run:" "${LABELS[@]}")

    if [[ -z "$SELECTED" ]]; then
      echo -e "${YELLOW}Nothing selected.${RESET}"
      exit 0
    fi

    gum confirm "Run $(echo "$SELECTED" | wc -l | tr -d ' ') selected scripts?" || exit 0

    while IFS= read -r label; do
      run_script "$label"
    done <<< "$SELECTED"
    ;;

  "Install ALL scripts")
    gum confirm "Run all ${#LABELS[@]} scripts?" || exit 0

    for label in "${LABELS[@]}"; do
      run_script "$label"
    done
    ;;
esac

echo ""
gum style \
  --foreground 2 \
  --bold \
  "All done!"
