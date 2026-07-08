#!/bin/sh
input=$(cat)

# ANSI 256-color helpers
# Usage: color <code> <text>
color() {
  printf '\033[38;5;%sm%s\033[0m' "$1" "$2"
}

# Model display name — color 111 (soft blue)
model_raw=$(echo "$input" | jq -r '.model.display_name // "unknown"')
model=$(color 111 "$model_raw")

# Format a raw token count to human-readable: 31k or 1M
format_k() {
  val=$1
  if [ -z "$val" ] || [ "$val" = "null" ]; then
    echo "?"
    return
  fi
  if [ "$val" -ge 1000000 ]; then
    printf "%dM" "$(echo "$val" | awk '{printf "%d", $1/1000000}')"
  elif [ "$val" -ge 1000 ]; then
    printf "%dk" "$(echo "$val" | awk '{printf "%d", $1/1000}')"
  else
    echo "$val"
  fi
}

# Token usage + context % merged — color 141 (lavender)
cur_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
cur_cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cur_cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

token_str=""
if [ -n "$cur_input" ] && [ -n "$ctx_size" ]; then
  total_used=$(echo "$cur_input $cur_cache_read $cur_cache_create" | awk '{print $1 + $2 + $3}')
  numerator=$(format_k "$total_used")
  denominator=$(format_k "$ctx_size")
  if [ -n "$used_pct" ]; then
    pct_int=$(printf '%.0f' "$used_pct")
    token_str=$(color 141 "${numerator}/${denominator} (${pct_int}%)")
  else
    token_str=$(color 141 "${numerator}/${denominator}")
  fi
fi

# 5-hour rate limit — soft orange
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
limit_str=""
if [ -n "$five_pct" ]; then
  limit_str=$(color 214 "$(printf '%.0f' "$five_pct")%")
fi

# Assemble parts
parts=""
append() {
  if [ -n "$1" ]; then
    if [ -n "$parts" ]; then
      parts="$parts  $1"
    else
      parts="$1"
    fi
  fi
}

append "$model"
append "$token_str"
append "$limit_str"

printf '%s' "$parts"
