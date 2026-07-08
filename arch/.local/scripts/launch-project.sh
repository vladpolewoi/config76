#!/bin/bash

PROJECT_DIR=~/code
PROJECT=$(ls "$PROJECT_DIR" | wofi --dmenu -i -p "Select Project")

[[ -z "$PROJECT" ]] && exit 1

SESSION_NAME="$PROJECT"
FULL_PATH="$PROJECT_DIR/$PROJECT"

detect_dev_cmd() {
  local pkg="$FULL_PATH/package.json"
  [[ ! -f "$pkg" ]] && return 1
  if jq -e '.scripts.dev' "$pkg" >/dev/null 2>&1; then
    if [[ -f "$FULL_PATH/pnpm-lock.yaml" ]]; then echo "pnpm dev"
    elif [[ -f "$FULL_PATH/yarn.lock"   ]]; then echo "yarn dev"
    else echo "npm run dev"; fi
  elif jq -e '.scripts.start' "$pkg" >/dev/null 2>&1; then
    echo "npm run start"
  else
    return 1
  fi
}

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  tmux new-session -d -s "$SESSION_NAME" -c "$FULL_PATH"
  tmux send-keys -t "$SESSION_NAME:0" 'nvim' C-m

  DEV_CMD=$(detect_dev_cmd)
  if [[ -n "$DEV_CMD" ]]; then
    tmux new-window -t "$SESSION_NAME" -n dev -c "$FULL_PATH"
    tmux send-keys -t "$SESSION_NAME:1" "$DEV_CMD" C-m
  fi
fi

kitty --working-directory "$FULL_PATH" tmux attach -t "$SESSION_NAME"
