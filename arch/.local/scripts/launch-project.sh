#!/bin/bash

PROJECT_DIR=~/code
PROJECT=$(ls "$PROJECT_DIR" | wofi --dmenu -i -p "Select Project")

[[ -z "$PROJECT" ]] && exit 1

SESSION_NAME="$PROJECT"
FULL_PATH="$PROJECT_DIR/$PROJECT"

# Check if session already exists
tmux has-session -t "$SESSION_NAME" 2>/dev/null
if [ $? != 0 ]; then
  tmux new-session -d -s "$SESSION_NAME" -c "$FULL_PATH"

  case "$PROJECT" in
    ui-kit)
      tmux send-keys -t "$SESSION_NAME:0" 'nvim' C-m
      tmux new-window -t "$SESSION_NAME" -n term -c "$FULL_PATH"
      tmux send-keys -t "$SESSION_NAME:1" 'npm run start' C-m
      ;;
    *)
      tmux send-keys -t "$SESSION_NAME:0" 'nvim' C-m
      ;;
  esac
fi

kitty --working-directory "$FULL_PATH" tmux attach -t "$SESSION_NAME"

