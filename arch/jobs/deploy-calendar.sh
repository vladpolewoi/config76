#!/bin/bash

# Deploy Calendar-App to DSD server
# Local CI/CD pipeline before deployment
# Usage: deploy-calendar.sh [--skip-tests] [--skip-lint]

set -e  # Exit on error

# Configuration
PROJECT_DIR="/home/user76/code/Calendar-App"
SSH_HOST="dsd-calendar"
REMOTE_DIR="/var/www/r7-office/calendar-app"
BUILD_DIR="dist"

# Flags
SKIP_LINT=false
SKIP_TESTS=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    --skip-lint) SKIP_LINT=true ;;
    --skip-tests) SKIP_TESTS=true ;;
  esac
done

# Check for gum
if ! command -v gum &>/dev/null; then
  echo "Error: gum is not installed. Run: sudo pacman -S gum"
  exit 1
fi

# Header
gum style \
  --border double \
  --border-foreground 212 \
  --padding "0 2" \
  --margin "1 0" \
  "Calendar-App Deploy Pipeline"

# Step 1: Navigate to project
gum log --level info "Navigating to project..."
cd "$PROJECT_DIR" || { gum log --level error "Project directory not found: $PROJECT_DIR"; exit 1; }
gum log --level info "Directory: $(pwd)"

# Step 2: Checkout to stage branch
gum log --level info "Checking out stage branch..."
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "stage" ]]; then
  gum log --level warn "Current branch: $CURRENT_BRANCH"
  gum spin --spinner dot --title "Fetching stage branch..." -- git fetch origin stage
  git checkout stage
  gum spin --spinner dot --title "Pulling latest..." -- git pull origin stage
  gum log --level info "Switched to stage branch"
else
  gum spin --spinner dot --title "Pulling latest..." -- git pull origin stage
  gum log --level info "Already on stage, pulled latest"
fi

# Step 3: Lint check
if [[ $SKIP_LINT == false ]]; then
  gum spin --spinner dot --title "Running ESLint..." -- npm run eslint
  gum log --level info "Lint passed"
else
  gum log --level warn "Skipping lint (--skip-lint)"
fi

# Step 4: TypeScript type check
gum spin --spinner dot --title "Running TypeScript check..." -- npx tsc --noEmit
gum log --level info "Type check passed"

# Step 5: E2E Tests
if [[ $SKIP_TESTS == false ]]; then
  # TODO: Add Playwright tests
  # gum spin --spinner dot --title "Running E2E tests..." -- npx playwright test
  gum log --level warn "E2E tests not configured yet"
else
  gum log --level warn "Skipping tests (--skip-tests)"
fi

# Step 6: Build
gum spin --spinner dot --title "Building project..." -- npm run build
gum log --level info "Build completed"

# Verify build output
if [[ ! -d "$BUILD_DIR" ]]; then
  gum log --level error "Build directory not found: $BUILD_DIR"
  exit 1
fi

BUILD_SIZE=$(du -sh "$BUILD_DIR" | cut -f1)
FILE_COUNT=$(find "$BUILD_DIR" -type f | wc -l)
gum log --level info "Build output: $BUILD_SIZE ($FILE_COUNT files)"

# Step 7: Deploy to server
gum spin --spinner dot --title "Uploading to server..." -- rsync -avz --delete "$BUILD_DIR/" "$SSH_HOST:$REMOTE_DIR/"
gum log --level info "Upload completed"

# Step 8: Reload nginx
gum spin --spinner dot --title "Reloading nginx..." -- ssh "$SSH_HOST" "sudo systemctl reload nginx"
gum log --level info "Nginx reloaded"

# Footer
echo ""
gum style \
  --border double \
  --border-foreground 82 \
  --padding "0 2" \
  --margin "1 0" \
  "Deploy Complete!" \
  "Deployed to: $SSH_HOST:$REMOTE_DIR"
