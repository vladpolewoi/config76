#!/bin/bash
# Numbered-pin screenshot markup, straight into Claude's clipboard.
#
#   mark.sh <file>   mark an image (this is how shot-receiver.py calls it)
#   mark.sh region   region of this screen
#   mark.sh latest   newest image the phone pushed
#   mark.sh drop     newest image in ~/Downloads (LocalSend landing)
#
# Satty opens on the Numbered Marker tool: click = pin 1, click = pin 2, ...
# Enter saves and closes. A terminal then asks for one comment per pin, and
# the image path plus the numbered comments land on the clipboard as one paste.

set -uo pipefail

dir="$HOME/shots/$(date +%F)"
mkdir -p "$dir"

die() { notify-send -u critical "mark" "$1"; echo "$1" >&2; sleep 4; exit 1; }

newest() {
  find "$1" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) \
    -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-
}

# --- second pass: we were re-launched in a terminal just for the comments ---
if [ "${1:-}" = "--comments" ]; then
  out=$2
  echo "Marked: $out"
  echo "One comment per pin. Blank line ends."
  echo
  notes=""
  i=1
  while :; do
    read -rp "  $i. " line || break
    [ -z "$line" ] && break
    notes+="$i. $line"$'\n'
    i=$((i + 1))
  done
  printf '%s\n\n%s' "$out" "$notes" | wl-copy
  notify-send -t 1500 "mark" "$((i - 1)) pins — paste into Claude"
  exit 0
fi

# --- first pass: get an image, annotate it ---
src=${1:-region}
raw=""

case "$src" in
  region)
    geom=$(slurp) || exit 0
    raw="$dir/.raw-$$.png"
    grim -g "$geom" "$raw"
    ;;
  latest)
    raw=$(newest "$HOME/shots/inbox")
    [ -n "$raw" ] || die "nothing pushed from the phone yet"
    ;;
  drop)
    raw=$(newest "$HOME/Downloads")
    [ -n "$raw" ] || die "nothing image-shaped in ~/Downloads"
    ;;
  *)
    [ -f "$src" ] || die "no such file: $src"
    raw=$src
    ;;
esac

out="$dir/$(date +%H%M%S).png"
satty -f "$raw" -o "$out" \
  --initial-tool marker \
  --early-exit save \
  --actions-on-enter="save-to-file,exit" \
  --actions-on-escape=exit \
  --disable-notifications
[ -f "$out" ] || exit 0          # closed without saving
[[ "$raw" == "$dir/.raw-"* ]] && rm -f "$raw"
ln -sfn "$out" "$HOME/shots/latest.png"

if [ -t 0 ]; then
  exec "$0" --comments "$out"
else
  exec kitty --title "mark" -e "$0" --comments "$out"
fi
