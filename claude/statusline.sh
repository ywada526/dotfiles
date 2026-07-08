#!/usr/bin/env bash
# Claude Code status line: "dir (branch) | model | 12.3k (10%) | 5%/5h 7%/7d"
# Reads the statusLine JSON payload from stdin (see https://code.claude.com/docs/en/statusline).
set -euo pipefail

input=$(cat)

c_reset=$'\033[0m'
c_model=$'\033[96m'
c_sep=$'\033[90m'
c_green=$'\033[92m'
c_yellow=$'\033[93m'
c_red=$'\033[91m'

raw_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir=${raw_dir/#$HOME/\~}

model=$(echo "$input" | jq -r '.model.display_name // empty')

branch=""
if [ -n "$raw_dir" ] && git -C "$raw_dir" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$raw_dir" --no-optional-locks branch --show-current 2>/dev/null)
fi

# Default foreground so it adapts to light/dark terminal themes.
loc="$dir"
[ -n "$branch" ] && loc="$loc ($branch)"

token_color() {
  if [ "$1" -lt 100000 ]; then printf '%s' "$c_green"
  elif [ "$1" -lt 150000 ]; then printf '%s' "$c_yellow"
  else printf '%s' "$c_red"
  fi
}

limit_color() {
  if [ "$1" -lt 50 ]; then printf '%s' "$c_green"
  elif [ "$1" -lt 80 ]; then printf '%s' "$c_yellow"
  else printf '%s' "$c_red"
  fi
}

tokens=$(echo "$input" | jq -r '((.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)) | select(. > 0)')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx=""
if [ -n "$tokens" ]; then
  if [ "$tokens" -ge 1000 ]; then
    ctx=$(printf '%.1fk' "$(echo "$tokens" | awk '{print $1 / 1000}')")
  else
    ctx="$tokens"
  fi
  [ -n "$used" ] && ctx="$ctx ($(printf '%.0f' "$used")%)"
  ctx="$(token_color "$tokens")${ctx}${c_reset}"
fi

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
limits=""
if [ -n "$five" ]; then
  five_int=$(printf '%.0f' "$five")
  limits="$(limit_color "$five_int")${five_int}%/5h${c_reset}"
fi
if [ -n "$week" ]; then
  week_int=$(printf '%.0f' "$week")
  limits="${limits:+$limits }$(limit_color "$week_int")${week_int}%/7d${c_reset}"
fi

added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
diffstat=""
if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
  diffstat="${c_green}+${added}${c_reset} ${c_red}-${removed}${c_reset}"
fi

parts=("$loc")
[ -n "$diffstat" ] && parts+=("$diffstat")
[ -n "$model" ] && parts+=("${c_model}${model}${c_reset}")
[ -n "$ctx" ] && parts+=("$ctx")
[ -n "$limits" ] && parts+=("$limits")

output=""
for part in "${parts[@]}"; do
  if [ -z "$output" ]; then
    output="$part"
  else
    output="${output} ${c_sep}|${c_reset} ${part}"
  fi
done

printf '%s\n' "$output"
