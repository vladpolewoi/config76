#!/bin/bash
# Waybar module: tmux session count + tooltip with idle times.

ICON=$''  # nf-fa-terminal
NOW=$(date +%s)

sessions=$(tmux ls -F '#{session_name}|#{session_attached}|#{session_activity}' 2>/dev/null)

if [[ -z "$sessions" ]]; then
  printf '{"text":"%s 0","tooltip":"no tmux sessions","class":"empty"}\n' "$ICON"
  exit 0
fi

count=$(echo "$sessions" | wc -l)

tooltip=""
while IFS='|' read -r name attached activity; do
  idle=$((NOW - activity))
  if   (( idle < 60     )); then ago="${idle}s"
  elif (( idle < 3600   )); then ago="$((idle/60))m"
  elif (( idle < 86400  )); then ago="$((idle/3600))h"
  else                            ago="$((idle/86400))d"
  fi
  marker="·"
  [[ "$attached" == "1" ]] && marker="●"
  tooltip+="${marker} ${name}  (${ago})\n"
done <<< "$sessions"

tooltip=${tooltip%\\n}

class="ok"
(( count >= 3 )) && class="warn"

printf '{"text":"%s  %d","tooltip":"%s","class":"%s"}\n' "$ICON" "$count" "$tooltip" "$class"
