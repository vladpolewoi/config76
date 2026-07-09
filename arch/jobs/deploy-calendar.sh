#!/bin/bash

# Deploy Calendar-App to the DSD staging server.
#
# Modes:
#   deploy-calendar                       Interactive menu
#   deploy-calendar --branch <name>       Deploy <name> to the STAGING root
#   deploy-calendar --preview [--branch <name>] [--slug <slug>]
#                                         Deploy a branch to an isolated PREVIEW
#   deploy-calendar --list                List live previews
#   deploy-calendar --delete <slug>       Remove one preview
#
# Flags: --skip-lint
#
#   Staging  ->  https://calendar-dev.r7-office.ru/
#   Preview  ->  https://calendar-dev.r7-office.ru/previews/<slug>/
#
# Previews live in a SIBLING dir of the staging docroot, so a staging deploy
# (rsync --delete into the root) can never wipe them. Each preview is built with
# vite base=/previews/<slug>/ (build:cicd) and rsynced into its own subfolder;
# nginx serves them via one generic location block (no reload needed per preview).

set -e

# --- Configuration ----------------------------------------------------------
PROJECT_DIR="/home/user76/code/Calendar-App"
SSH_HOST="dsd-calendar"
STAGING_DIR="/var/www/r7-office/calendar-app"   # staging docroot (URL: /)
PREVIEW_BASE="/var/www/r7-office/previews"       # parent of all preview folders
PUBLIC_HOST="calendar-dev.r7-office.ru"
BUILD_DIR="dist"
PROJECTS_MCP_CLI="/home/user76/code/mcp-servers/projects-mcp/dist/cli.js"   # writes Preview Link to the board
PREVIEW_WT="/home/user76/code/Calendar-App-wt-preview"          # isolated checkout for preview builds
READY_STATUS="Ready to test"                                    # board status set after a preview deploy

# --- Flags / args -----------------------------------------------------------
MODE=""              # menu | staging | preview | list | delete
SKIP_LINT=false
DEPLOY_BRANCH=""
PREVIEW_SLUG=""
DELETE_SLUG=""
TASK_KEY=""          # board task key (e.g. KLNA-2); auto-derived from branch if empty
NO_BOARD=false       # skip all board updates (Preview Link + status)
NO_STATUS=false      # skip only the "Ready to test" status move

while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)    DEPLOY_BRANCH="$2"; shift 2 ;;
    --preview)   MODE="preview"; shift ;;
    --slug)      PREVIEW_SLUG="$2"; shift 2 ;;
    --list)      MODE="list"; shift ;;
    --delete)    MODE="delete"; DELETE_SLUG="$2"; shift 2 ;;
    --task)      TASK_KEY="$2"; shift 2 ;;
    --no-board)  NO_BOARD=true; shift ;;
    --no-status) NO_STATUS=true; shift ;;
    --skip-lint) SKIP_LINT=true; shift ;;
    --skip-tests) shift ;;                       # accepted for back-compat (no-op)
    *)           shift ;;
  esac
done

# --branch without --preview means a staging deploy; bare invocation -> menu.
if [[ -z "$MODE" ]]; then
  if [[ -n "$DEPLOY_BRANCH" ]]; then MODE="staging"; else MODE="menu"; fi
fi

# --- Preconditions ----------------------------------------------------------
command -v gum >/dev/null 2>&1 || { echo "Error: gum not installed. Run: sudo pacman -S gum"; exit 1; }
cd "$PROJECT_DIR" || { echo "Project dir not found: $PROJECT_DIR"; exit 1; }

# --- Helpers ----------------------------------------------------------------
slugify() {
  # Free text / branch name -> url-safe slug.
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's#[^a-z0-9]+#-#g; s#^-+|-+$##g'
}

derive_task_key() {
  # Pull a board key (KLNA-NN) out of a branch name; empty if none.
  echo "$1" | grep -oiE 'KLNA-[0-9]+' | head -1 | tr '[:lower:]' '[:upper:]'
}

write_board_link() {  # $1 = task key, $2 = url
  local key="$1" url="$2" out
  if [[ -z "$key" ]]; then
    gum log --level warn "No KLNA key in branch — skipping board update (pass --task KLNA-NN to set)"
    return 0
  fi
  if [[ ! -f "$PROJECTS_MCP_CLI" ]]; then
    gum log --level warn "projects-mcp CLI not built ($PROJECTS_MCP_CLI) — skipping board update"
    return 0
  fi
  if out="$(node "$PROJECTS_MCP_CLI" set-preview-link "$key" "$url" 2>&1)"; then
    gum log --level info "Board: $out"
  else
    gum log --level warn "Board update failed for $key: $out"
  fi
}

move_board_status() {  # $1 = task key, $2 = status name
  local key="$1" status="$2" out
  [[ -n "$key" ]] || return 0
  [[ -f "$PROJECTS_MCP_CLI" ]] || return 0
  if out="$(node "$PROJECTS_MCP_CLI" set-status "$key" "$status" 2>&1)"; then
    gum log --level info "Board: $out"
  else
    gum log --level warn "Board status move failed for $key: $out"
  fi
}

# Check out a branch's committed tip into a dedicated worktree, leaving the main
# working dir (and any uncommitted edits) completely untouched. Detached HEAD so
# it works even when the branch is checked out in the main repo or another tree.
prepare_preview_worktree() {  # $1 = branch
  local branch="$1" lock_hash stored
  if ! git -C "$PROJECT_DIR" worktree list --porcelain | grep -qx "worktree $PREVIEW_WT"; then
    gum log --level info "Creating preview worktree: $PREVIEW_WT"
    git -C "$PROJECT_DIR" worktree add --detach "$PREVIEW_WT" HEAD
  fi
  gum spin --spinner dot --title "Fetching $branch..." -- git -C "$PROJECT_DIR" fetch origin "$branch" || true
  gum spin --spinner dot --title "Checking out $branch (committed tip)..." -- bash -c "
    git -C '$PREVIEW_WT' reset --hard >/dev/null 2>&1 || true
    git -C '$PREVIEW_WT' checkout --detach '$branch' &&
    git -C '$PREVIEW_WT' reset --hard '$branch' &&
    git -C '$PREVIEW_WT' clean -fd -e node_modules -e .preview-deps-hash >/dev/null 2>&1 || true
  "
  gum log --level info "Worktree at $branch @ $(git -C "$PREVIEW_WT" rev-parse --short HEAD)"
  # Install deps only when package-lock changed (first run is slower).
  lock_hash="$(sha1sum "$PREVIEW_WT/package-lock.json" | cut -d' ' -f1)"
  stored="$(cat "$PREVIEW_WT/.preview-deps-hash" 2>/dev/null || true)"
  if [[ ! -d "$PREVIEW_WT/node_modules" || "$lock_hash" != "$stored" ]]; then
    gum spin --spinner dot --title "Installing deps (npm ci)..." -- bash -c "cd '$PREVIEW_WT' && npm ci"
    echo "$lock_hash" > "$PREVIEW_WT/.preview-deps-hash"
  else
    gum log --level info "Deps up to date"
  fi
}

header()  { gum style --border double --border-foreground 212 --padding "0 2" --margin "1 0" "$@"; }
success() { gum style --border double --border-foreground 82  --padding "0 2" --margin "1 0" "$@"; }

checkout_branch() {  # $1 = branch
  local target="$1"
  ORIG_BRANCH="$(git branch --show-current)"
  if [[ "$ORIG_BRANCH" != "$target" ]]; then
    gum log --level warn "Current branch: $ORIG_BRANCH"
    gum spin --spinner dot --title "Fetching $target..." -- git fetch origin "$target"
    git checkout "$target"
    SWITCHED=true
  else
    SWITCHED=false
  fi
  gum spin --spinner dot --title "Pulling latest..." -- git pull origin "$target"
  gum log --level info "On $target (latest)"
}

restore_branch() {
  if [[ "${SWITCHED:-false}" == true ]]; then
    git checkout "$ORIG_BRANCH"
    gum log --level info "Switched back to $ORIG_BRANCH"
  fi
}

run_checks() {
  if [[ $SKIP_LINT == false ]]; then
    gum spin --spinner dot --title "Running ESLint..." -- npm run eslint
    gum log --level info "Lint passed"
  else
    gum log --level warn "Skipping lint (--skip-lint)"
  fi
  gum spin --spinner dot --title "Running TypeScript check..." -- npx tsc --noEmit
  gum log --level info "Type check passed"
}

verify_build() {
  [[ -d "$BUILD_DIR" ]] || { gum log --level error "Build dir not found: $BUILD_DIR"; exit 1; }
  gum log --level info "Build output: $(du -sh "$BUILD_DIR" | cut -f1) ($(find "$BUILD_DIR" -type f | wc -l) files)"
}

# --- Modes ------------------------------------------------------------------
deploy_staging() {  # $1 = branch
  header "Calendar-App  ·  STAGING deploy"
  checkout_branch "$1"
  run_checks
  gum spin --spinner dot --title "Building (production)..." -- npm run build
  verify_build
  gum spin --spinner dot --title "Uploading to staging root..." -- \
    rsync -avz --delete "$BUILD_DIR/" "$SSH_HOST:$STAGING_DIR/"
  gum spin --spinner dot --title "Reloading nginx..." -- ssh "$SSH_HOST" "sudo systemctl reload nginx"
  restore_branch
  success "Deploy Complete!" "Mode: STAGING" "Branch: $1" "URL: https://$PUBLIC_HOST/"
}

deploy_preview() {  # $1 = branch, $2 = slug
  local branch="$1" slug="$2" wt_dist="$PREVIEW_WT/$BUILD_DIR"
  header "Calendar-App  ·  PREVIEW deploy (isolated worktree)"
  prepare_preview_worktree "$branch"
  # Lint + type-check + build the committed code IN the worktree; main tree untouched.
  ( cd "$PREVIEW_WT" && run_checks )
  gum spin --spinner dot --title "Building (base /previews/$slug/)..." -- \
    bash -c "cd '$PREVIEW_WT' && npm run build:cicd --preview_link_uuid='previews/$slug'"
  [[ -d "$wt_dist" ]] || { gum log --level error "Build dir not found: $wt_dist"; exit 1; }
  gum log --level info "Build: $(du -sh "$wt_dist" | cut -f1) ($(find "$wt_dist" -type f | wc -l) files)"
  gum spin --spinner dot --title "Creating remote dir..." -- \
    ssh "$SSH_HOST" "mkdir -p '$PREVIEW_BASE/$slug'"
  gum spin --spinner dot --title "Uploading preview..." -- \
    rsync -avz --delete "$wt_dist/" "$SSH_HOST:$PREVIEW_BASE/$slug/"
  success "Deploy Complete!" "Mode: PREVIEW" "Branch: $branch" "Slug: $slug" \
    "URL: https://$PUBLIC_HOST/previews/$slug/"
  if [[ "$NO_BOARD" != true ]]; then
    write_board_link "$TASK_KEY" "https://$PUBLIC_HOST/previews/$slug/"
    [[ "$NO_STATUS" == true ]] || move_board_status "$TASK_KEY" "$READY_STATUS"
  fi
}

list_previews() {
  header "Calendar-App  ·  live previews"
  local out
  out="$(ssh "$SSH_HOST" "ls -1 '$PREVIEW_BASE' 2>/dev/null" || true)"
  if [[ -z "$out" ]]; then
    gum log --level info "No previews deployed"
    return
  fi
  while IFS= read -r s; do
    [[ -n "$s" ]] && echo "  • $s  →  https://$PUBLIC_HOST/previews/$s/"
  done <<< "$out"
}

delete_preview() {  # $1 = slug
  local slug="$1"
  [[ -n "$slug" ]] || { gum log --level error "No slug given"; exit 1; }
  if gum confirm "Delete preview '$slug'?"; then
    ssh "$SSH_HOST" "rm -rf '${PREVIEW_BASE:?}/$slug'"
    gum log --level info "Deleted preview: $slug"
  else
    gum log --level warn "Cancelled"
  fi
}

# --- Menu -------------------------------------------------------------------
if [[ "$MODE" == "menu" ]]; then
  action="$(gum choose --header "What do you want to do?" \
    "Deploy staging" "Deploy preview" "List previews" "Delete preview")"
  case "$action" in
    "Deploy staging") MODE="staging" ;;
    "Deploy preview") MODE="preview" ;;
    "List previews")  MODE="list" ;;
    "Delete preview") MODE="delete" ;;
    *) exit 0 ;;
  esac
fi

# --- Dispatch ---------------------------------------------------------------
case "$MODE" in
  staging)
    if [[ -z "$DEPLOY_BRANCH" ]]; then
      cur="$(git branch --show-current)"
      DEPLOY_BRANCH="$(gum choose --header "Deploy which branch to STAGING?" "stage" "$cur" --selected "$cur")"
    fi
    deploy_staging "$DEPLOY_BRANCH"
    ;;
  preview)
    if [[ -z "$DEPLOY_BRANCH" ]]; then
      cur="$(git branch --show-current)"
      DEPLOY_BRANCH="$(gum choose --header "Preview which branch?" "$cur" "stage" --selected "$cur")"
    fi
    [[ -n "$PREVIEW_SLUG" ]] || PREVIEW_SLUG="$DEPLOY_BRANCH"
    PREVIEW_SLUG="$(slugify "$PREVIEW_SLUG")"
    [[ -n "$TASK_KEY" ]] || TASK_KEY="$(derive_task_key "$DEPLOY_BRANCH")"
    deploy_preview "$DEPLOY_BRANCH" "$PREVIEW_SLUG"
    ;;
  list)
    list_previews
    ;;
  delete)
    if [[ -z "$DELETE_SLUG" ]]; then
      avail="$(ssh "$SSH_HOST" "ls -1 '$PREVIEW_BASE' 2>/dev/null" || true)"
      [[ -n "$avail" ]] || { gum log --level info "No previews to delete"; exit 0; }
      DELETE_SLUG="$(echo "$avail" | gum choose --header "Delete which preview?")"
    fi
    delete_preview "$(slugify "$DELETE_SLUG")"
    ;;
esac
