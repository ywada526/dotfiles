# zoxide wrapper: run interactive zi when called with no args, otherwise forward to z.
c() { if [ $# -eq 0 ]; then zi; else z "$@"; fi }

# Generate a Conventional Commits message from the staged diff via codex (gpt-5.6-luna) and commit.
gc() {
  local schema='{"type":"object","properties":{"commit_message":{"type":"string","description":"A git commit message in imperative mood, Conventional Commits format"}},"required":["commit_message"],"additionalProperties":false}'
  git diff --cached \
    | codex exec --ephemeral --dangerously-bypass-approvals-and-sandbox -m gpt-5.6-luna -c model_reasoning_effort=low --output-schema <(print -r -- "$schema") --json "Write a Conventional Commits message for this diff, imperative mood." \
    | jq -rs 'map(select(.type == "item.completed" and .item.type == "agent_message"))[-1].item.text | fromjson | .commit_message' \
    | git commit -F -
}

# Delete local branches merged into the current branch, removing their linked worktrees first.
gx() {
  git fetch --prune
  git worktree prune
  local b wt
  for b in $(git branch --merged | sed "s/^[*+] //" | grep -Ev "^($(git symbolic-ref --short refs/remotes/origin/HEAD | sed "s|^origin/||"))$"); do
    wt=$(git worktree list --porcelain | grep -B2 "branch refs/heads/$b$" | head -1 | cut -d" " -f2)
    [ -n "$wt" ] && git worktree remove "$wt"
    git branch -D "$b"
  done
}
