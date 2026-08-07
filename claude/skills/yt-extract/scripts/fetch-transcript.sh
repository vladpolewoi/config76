#!/usr/bin/env bash
# fetch-transcript.sh <youtube-url-or-id> <output-dir> [lang1 lang2 ...]
# Writes <output-dir>/<video-id>.txt, prints "<id>: <words> words".
# Default language preference: en ru. On language miss, retries with
# whatever the error says is available.
set -euo pipefail

input="${1:?usage: fetch-transcript.sh <url-or-id> <outdir> [langs...]}"
outdir="${2:?usage: fetch-transcript.sh <url-or-id> <outdir> [langs...]}"
shift 2
langs=("${@:-en}" )
[ $# -eq 0 ] && langs=(en ru)

# Extract 11-char video ID from any YouTube URL form (watch?v=, youtu.be/, shorts/, live/)
id=$(printf '%s' "$input" | grep -oE '(v=|youtu\.be/|shorts/|live/)[A-Za-z0-9_-]{11}' | head -1 | grep -oE '[A-Za-z0-9_-]{11}$' || true)
[ -z "$id" ] && id=$(printf '%s' "$input" | grep -oE '^[A-Za-z0-9_-]{11}$' || true)
[ -z "$id" ] && { echo "ERROR: could not parse video id from: $input" >&2; exit 1; }

mkdir -p "$outdir"
out="$outdir/$id.txt"
err=$(mktemp)

if uvx --from youtube-transcript-api youtube_transcript_api "$id" \
    --languages "${langs[@]}" --format text >"$out" 2>"$err" \
    && [ -s "$out" ] && ! grep -q "Could not retrieve" "$out"; then
  echo "$id: $(wc -w <"$out") words -> $out"
  rm -f "$err"
  exit 0
fi

# Language miss: the tool prints available codes like:  - ru ("Russian ...")
avail=$(grep -hoE '^ - [a-zA-Z-]+' "$out" "$err" 2>/dev/null | awk '{print $2}' | head -5 || true)
if [ -n "$avail" ]; then
  echo "requested langs unavailable; retrying with: $avail" >&2
  # shellcheck disable=SC2086
  if uvx --from youtube-transcript-api youtube_transcript_api "$id" \
      --languages $avail --format text >"$out" 2>"$err" && [ -s "$out" ]; then
    echo "$id: $(wc -w <"$out") words -> $out"
    rm -f "$err"
    exit 0
  fi
fi

echo "ERROR: transcript fetch failed for $id" >&2
grep -q "blocking requests from your IP" "$out" "$err" 2>/dev/null \
  && echo "HINT: YouTube IP rate-limit — wait 15-60 min, then retry with >=30s gaps between videos" >&2
cat "$err" >&2
rm -f "$err" "$out"   # never leave error text behind as a fake transcript
exit 1
