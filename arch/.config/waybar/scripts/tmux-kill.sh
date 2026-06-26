#!/bin/bash
# Pick a tmux session via wofi and kill it.

NOW=$(date +%s)

list=$(tmux ls -F '#{session_name}|#{session_attached}|#{session_activity}' 2>/dev/null)
[[ -z "$list" ]] && exit 0

menu=$(while IFS='|' read -r name attached activity; do
  idle=$((NOW - activity))
  if   (( idle < 60    )); then ago="${idle}s"
  elif (( idle < 3600  )); then ago="$((idle/60))m"
  elif (( idle < 86400 )); then ago="$((idle/3600))h"
  else                           ago="$((idle/86400))d"
  fi
  marker="·"
  [[ "$attached" == "1" ]] && marker="●"
  printf '%s %s  (idle %s)\n' "$marker" "$name" "$ago"
done <<< "$list")

pick=$(echo "$menu" | wofi --dmenu -i -p "Kill tmux session")
[[ -z "$pick" ]] && exit 0

# Extract session name (2nd field)
name=$(echo "$pick" | awk '{print $2}')
[[ -z "$name" ]] && exit 0

tmux kill-session -t "$name" && {
  notify-send "tmux" "killed: $name"
  pkill -SIGRTMIN+8 waybar
}
