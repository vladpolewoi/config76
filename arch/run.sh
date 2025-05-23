#!/bin/bash

script_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
filter=""
dry="0"

# Parse arguments
while [[ $# > 0 ]]; do
  if [[ $1 == "--dry" ]]; then
    dry="1"
  else
    filter="$1"
  fi
  shift
done

# Log with prefix
log() {
  if [[ $dry == "1" ]]; then
    echo "[DRY_RUN]: $@"
  else
    echo "$@"
  fi
}

# Execute with dry-run check and logging
execute() {
  log "execute $@"

  if [[ $dry == "1" ]]; then
    return
  fi
  "$@"
}

log "$script_dir --$filter"

cd $script_dir
scripts=$(find ./runs -maxdepth 2 -mindepth 1 -executable -type f)

# Run scripts
for script in $scripts; do
  if echo "$script" | grep -qv "$filter"; then
    log "filtering $script"
    continue
  fi

  execute ./$script
done

