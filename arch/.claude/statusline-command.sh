#!/usr/bin/env bash
# Claude Code statusline — polished, Nerd Font glyphs, ANSI colours
# Segments: model · dir · git · context · output-style

input=$(cat)

# ── Colours ────────────────────────────────────────────────────────────────
reset='\033[0m'
bold='\033[1m'
dim='\033[2m'

# Foreground palette (256-colour)
fg_purple='\033[38;5;141m'   # model
fg_cyan='\033[38;5;81m'      # dir
fg_green='\033[38;5;114m'    # git branch
fg_red='\033[38;5;203m'      # git dirty
fg_yellow='\033[38;5;221m'   # context bar
fg_orange='\033[38;5;215m'   # context high-usage warning
fg_blue='\033[38;5;75m'      # output style
fg_dim='\033[38;5;240m'      # separators / less-important text

sep="${fg_dim}•${reset}"      # subtle bullet separator

# ── Parse JSON input ────────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model_name=$(echo "$input" | jq -r '.model.display_name // ""')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
output_style=$(echo "$input" | jq -r '.output_style.name // ""')
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# ── Segment 1: Model ────────────────────────────────────────────────────────
model_seg=""
if [ -n "$model_name" ]; then
  # Strip common prefixes/suffixes for brevity: "Claude 3.5 Sonnet" → "3.5 Sonnet"
  short_model=$(echo "$model_name" | sed 's/^[Cc]laude[[:space:]]*//')
  model_seg="${fg_purple} ${bold}${short_model}${reset}"
fi

# ── Segment 2: Directory (basename only) ────────────────────────────────────
dir_seg=""
if [ -n "$cwd" ]; then
  basename_cwd=$(basename "$cwd")
  dir_seg="${fg_cyan} ${bold}${basename_cwd}${reset}"
fi

# ── Segment 3: Git branch + dirty indicator ─────────────────────────────────
git_seg=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || \
       ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
      dirty="${fg_red}*${reset}"
    else
      dirty=""
    fi
    git_seg="${fg_green} ${bold}${branch}${reset}${dirty}"
  fi
fi

# ── Segment 4: Context token usage ─────────────────────────────────────────
# Read the transcript jsonl and pull usage from the last assistant message
# that has a usage block (i.e., the last main-chain API response).
ctx_seg=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  # Extract last usage block: sum input+output+cache_creation+cache_read tokens
  usage_json=$(grep -o '"usage":{[^}]*}' "$transcript_path" 2>/dev/null | tail -1)
  if [ -n "$usage_json" ]; then
    input_tok=$(echo "$usage_json" | grep -o '"input_tokens":[0-9]*' | grep -o '[0-9]*$' || echo 0)
    output_tok=$(echo "$usage_json" | grep -o '"output_tokens":[0-9]*' | grep -o '[0-9]*$' || echo 0)
    cache_creation=$(echo "$usage_json" | grep -o '"cache_creation_input_tokens":[0-9]*' | grep -o '[0-9]*$' || echo 0)
    cache_read=$(echo "$usage_json" | grep -o '"cache_read_input_tokens":[0-9]*' | grep -o '[0-9]*$' || echo 0)

    # Default 0 if empty
    input_tok=${input_tok:-0}
    output_tok=${output_tok:-0}
    cache_creation=${cache_creation:-0}
    cache_read=${cache_read:-0}

    total_used=$((input_tok + output_tok + cache_creation + cache_read))

    # Budget: 1M for 1M-context models, 200k otherwise
    if [ "$context_window_size" -ge 900000 ] 2>/dev/null; then
      budget=1000000
    else
      budget=${context_window_size:-200000}
    fi

    pct=$(( total_used * 100 / budget ))

    # Format token count: show as "123k" if >= 1000
    if [ "$total_used" -ge 1000 ]; then
      display_tok="$(( total_used / 1000 ))k"
    else
      display_tok="${total_used}"
    fi

    # Budget display
    if [ "$budget" -ge 1000000 ]; then
      display_budget="1M"
    else
      display_budget="$(( budget / 1000 ))k"
    fi

    # Colour shifts when usage climbs
    if [ "$pct" -ge 80 ]; then
      ctx_colour="${fg_red}"
    elif [ "$pct" -ge 50 ]; then
      ctx_colour="${fg_orange}"
    else
      ctx_colour="${fg_yellow}"
    fi

    ctx_seg="${ctx_colour}󰾨 ${bold}${display_tok}/${display_budget}${reset}${ctx_colour} (${pct}%)${reset}"
  fi
fi

# Fallback: use pre-calculated field if transcript parse yielded nothing
if [ -z "$ctx_seg" ]; then
  used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
  if [ -n "$used_pct" ]; then
    pct=$(printf '%.0f' "$used_pct")
    if [ "$pct" -ge 80 ]; then
      ctx_colour="${fg_red}"
    elif [ "$pct" -ge 50 ]; then
      ctx_colour="${fg_orange}"
    else
      ctx_colour="${fg_yellow}"
    fi
    ctx_seg="${ctx_colour}󰾨 ${bold}${pct}%${reset}"
  fi
fi

# ── Segment 5: Claude usage limits (5h block) ──────────────────────────────
# Uses ccusage to read local transcript history; cached to /tmp with TTL.
limits_seg=""
cache_file="/tmp/claude-ccusage-cache.json"
cache_ttl=30  # seconds

cache_age=9999
if [ -f "$cache_file" ]; then
  cache_mtime=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
  now_epoch=$(date +%s)
  cache_age=$(( now_epoch - cache_mtime ))
fi

# If cache stale, fire-and-forget background refresh (non-blocking).
if [ "$cache_age" -gt "$cache_ttl" ]; then
  ( npx -y ccusage@latest blocks --json --active > "${cache_file}.tmp" 2>/dev/null \
      && mv "${cache_file}.tmp" "$cache_file" ) >/dev/null 2>&1 &
  disown 2>/dev/null
fi

if [ -f "$cache_file" ]; then
  block_start=$(jq -r '.blocks[0].startTime // empty' "$cache_file" 2>/dev/null)
  block_end=$(jq -r '.blocks[0].endTime // empty' "$cache_file" 2>/dev/null)
  block_active=$(jq -r '.blocks[0].isActive // false' "$cache_file" 2>/dev/null)

  if [ "$block_active" = "true" ] && [ -n "$block_start" ] && [ -n "$block_end" ]; then
    start_epoch=$(date -d "$block_start" +%s 2>/dev/null)
    end_epoch=$(date -d "$block_end" +%s 2>/dev/null)
    now_epoch=$(date +%s)
    if [ -n "$start_epoch" ] && [ -n "$end_epoch" ]; then
      total=$(( end_epoch - start_epoch ))
      elapsed=$(( now_epoch - start_epoch ))
      if [ "$total" -gt 0 ] && [ "$elapsed" -ge 0 ]; then
        block_pct=$(( elapsed * 100 / total ))
        [ "$block_pct" -gt 100 ] && block_pct=100
        if [ "$block_pct" -ge 80 ]; then
          lim_colour="${fg_red}"
        elif [ "$block_pct" -ge 50 ]; then
          lim_colour="${fg_orange}"
        else
          lim_colour="${fg_yellow}"
        fi
        limits_seg="${lim_colour}󱎫 ${bold}${block_pct}%${reset}"
      fi
    fi
  fi
fi

# ── Segment 6: Output style (only when non-default) ─────────────────────────
style_seg=""
if [ -n "$output_style" ] && [ "$output_style" != "default" ] && [ "$output_style" != "Default" ]; then
  style_seg="${fg_blue}󰉿 ${output_style}${reset}"
fi

# ── Assemble output ─────────────────────────────────────────────────────────
out=""
segments=("$model_seg" "$dir_seg" "$git_seg" "$ctx_seg" "$limits_seg" "$style_seg")
for seg in "${segments[@]}"; do
  if [ -n "$seg" ]; then
    if [ -n "$out" ]; then
      out="${out}  ${sep}  ${seg}"
    else
      out="${seg}"
    fi
  fi
done

printf "%b" "$out"
