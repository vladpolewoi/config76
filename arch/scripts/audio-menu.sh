#!/usr/bin/env bash
set -e

# Get sinks from wpctl status
choices="$(wpctl status 2>/dev/null | \
  sed -n '/Sinks:/,/Sources:/p' | \
  grep -E '^\s*│?\s*\*?\s*[0-9]+\.' | \
  sed -E 's/^[^0-9*]*\*?\s*([0-9]+)\.\s*(.+)\s*\[vol:.*/\1\t\2/' | \
  sed 's/[[:space:]]*$//')"

picked="$(printf "%s\n" "$choices" | wofi --dmenu --prompt "Audio output")"
[ -z "$picked" ] && exit 0

id="$(printf "%s" "$picked" | awk '{print $1}')"
wpctl set-default "$id"

