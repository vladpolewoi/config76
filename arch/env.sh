#!/usr/bin/env bash

script_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
echo $script_dir

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

log "-#@ dev @#-"

copy_dir() {
  from=$1
  to=$2

  pushd "$from" > /dev/null 
  dirs=$(find . -mindepth 1 -maxdepth 1 -type d)
  for dir in $dirs; do
	  if [ -d "$to/$dir" ]; then
	  	execute rm -rf "$to/$dir"
	  fi
	  execute cp -r "$dir" "$to/$dir"
  done
  popd > /dev/null 
}

copy_file() {
  from=$1
  to=$2
  name=$(basename $from)

  execute rm "$to/$name"
  execute cp "$from" "$to/$name"
}

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
copy_dir .config $XDG_CONFIG_HOME
copy_file .zshrc $HOME
copy_file .zprofile $HOME
# copy_dir .local $HOME/.local 
# copy_file .specialconfig $HOME
# copy_file .ready-tmux $HOME
