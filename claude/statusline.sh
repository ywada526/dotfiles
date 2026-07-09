#!/usr/bin/env bash
# Claude Code status line: "dir (branch) | +N -M | ↑ahead ↓behind | model | 12.3k (10%)"
# dir is always the project directory's basename (not the full path). In a
# worktree, it's the main worktree's basename, prefixed with "[worktree]".
# Reads the statusLine JSON payload from stdin (see https://code.claude.com/docs/en/statusline).
set -euo pipefail

input=$(cat)

c_reset=$'\033[0m'
c_model=$'\033[96m'
c_sep=$'\033[90m'
c_green=$'\033[92m'
c_yellow=$'\033[93m'
c_red=$'\033[91m'

# Pull every field in one jq call instead of re-parsing $input per field.
# Fields are joined with \x1f (not tab) because bash's `read` collapses
# consecutive IFS-whitespace delimiters, which would misalign empty fields.
IFS=$'\x1f' read -r raw_dir model tokens used <<<"$(jq -r '
  [
    (.workspace.current_dir // .cwd // ""),
    (.model.display_name // ""),
    (((.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)) as $t
      | if $t > 0 then ($t | tostring) else "" end),
    (.context_window.used_percentage // "" | tostring)
  ] | join("")
' <<<"$input")"

branch=""
project_dir="$raw_dir"
is_worktree=false
in_git_repo=false
if [ -n "$raw_dir" ] && git -C "$raw_dir" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  in_git_repo=true
  branch=$(git -C "$raw_dir" --no-optional-locks branch --show-current 2>/dev/null)
  git_dir=$(git -C "$raw_dir" --no-optional-locks rev-parse --path-format=absolute --git-dir 2>/dev/null)
  common_dir=$(git -C "$raw_dir" --no-optional-locks rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  # A linked worktree's git-dir differs from the common git-dir; the common
  # dir's parent is the main worktree, which we treat as the project root.
  if [ -n "$common_dir" ] && [ "$git_dir" != "$common_dir" ]; then
    is_worktree=true
    project_dir=$(dirname "$common_dir")
  fi
fi

dir=$(basename "$project_dir")

# Default foreground so it adapts to light/dark terminal themes.
loc="$dir"
[ -n "$branch" ] && loc="$loc ($branch)"
[ "$is_worktree" = true ] && loc="[worktree] $loc"

# Uncommitted tracked-file changes (staged + unstaged) and how far the local
# branch has diverged from its upstream. Both are local-only plumbing
# commands (no fetch), so the added cost per invocation is a couple of git
# processes, not a network round-trip.
uncommitted_added=0
uncommitted_removed=0
ahead=0
behind=0
if [ "$in_git_repo" = true ]; then
  if git -C "$raw_dir" --no-optional-locks rev-parse --verify -q HEAD >/dev/null 2>&1; then
    read -r uncommitted_added uncommitted_removed <<<"$(git -C "$raw_dir" --no-optional-locks diff HEAD --numstat 2>/dev/null | awk '{ if ($1 != "-") a += $1; if ($2 != "-") r += $2 } END { print a+0, r+0 }')"
  fi
  if git -C "$raw_dir" --no-optional-locks rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
    read -r ahead behind <<<"$(git -C "$raw_dir" --no-optional-locks rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)"
  fi
fi

token_color() {
  if [ "$1" -lt 100000 ]; then printf '%s' "$c_green"
  elif [ "$1" -lt 150000 ]; then printf '%s' "$c_yellow"
  else printf '%s' "$c_red"
  fi
}

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

diffstat=""
if [ "$uncommitted_added" -gt 0 ] || [ "$uncommitted_removed" -gt 0 ]; then
  diffstat="${c_green}+${uncommitted_added}${c_reset} ${c_red}-${uncommitted_removed}${c_reset}"
fi

sync=""
if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
  [ "$ahead" -gt 0 ] && sync="${c_green}↑${ahead}${c_reset}"
  [ "$behind" -gt 0 ] && sync="${sync:+$sync }${c_red}↓${behind}${c_reset}"
fi

parts=("$loc")
[ -n "$diffstat" ] && parts+=("$diffstat")
[ -n "$sync" ] && parts+=("$sync")
[ -n "$model" ] && parts+=("${c_model}${model}${c_reset}")
[ -n "$ctx" ] && parts+=("$ctx")

output=""
for part in "${parts[@]}"; do
  if [ -z "$output" ]; then
    output="$part"
  else
    output="${output} ${c_sep}|${c_reset} ${part}"
  fi
done

printf '%s\n' "$output"
