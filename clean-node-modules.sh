#!/bin/bash

# Get input path and options
START_PATH="$1"
DRY_RUN=false

if [ -z "$START_PATH" ]; then
  echo "❌ Usage: $0 <start_path> [--dry]"
  exit 1
fi

# Check if --dry is passed
if [[ "$2" == "--dry" ]]; then
  DRY_RUN=true
fi

echo "🔍 Searching for node_modules folders in: $START_PATH"
$DRY_RUN && echo "⚠️ Dry run mode is ON — no folders will be deleted."

# Find and act on node_modules folders
find "$START_PATH" -type d -name "node_modules" -prune -print | while read -r dir; do
  if $DRY_RUN; then
    echo "🧹 Would delete: $dir"
  else
    echo "🗑️ Deleting: $dir"
    rm -rf "$dir"
  fi
done

echo "✅ Done."

