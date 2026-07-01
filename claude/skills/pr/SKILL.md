---
name: pr
description: Rebase the current branch onto the remote default branch, then create or update its pull request. Use when the user runs /pr or asks to open or refresh a PR for the current branch.
---

# pr

Sync the current branch with the remote default branch via rebase as a preflight step, then create the branch's pull request or update the existing one.

## 1. Preflight

- Resolve the default branch: `base=$(git remote show origin | sed -n 's/.*HEAD branch: //p')`, falling back to `main` if empty.
- If the current branch (`git branch --show-current`) equals `$base`, create and switch to a new feature branch first (`git switch -c <name>`), deriving the name from the pending changes. Do this before committing so nothing lands on `$base`.
- Run `git status --porcelain`. If the working tree is dirty, commit the outstanding changes before rebasing — never rebase over uncommitted changes. Whether that is one commit or several is case by case.

## 2. Rebase onto the remote default branch

- `git fetch origin`
- `git rebase "origin/$base"`
- On conflict: attempt to resolve it. For hunks where the correct resolution is unclear, stop and ask the user. Do not run `git rebase --abort` without confirmation.

## 3. Push

```sh
if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
  # Existing upstream: the rebase may have rewritten history. --force-with-lease only
  # overwrites when the remote is at the value we expect; --force-if-includes additionally
  # requires the remote tip to already be integrated locally, so a stray background fetch
  # can't trick the lease into clobbering unseen work. Both guards no-op on a fast-forward.
  git push --force-with-lease --force-if-includes
else
  git push -u origin HEAD
fi
```

## 4. Create or update the PR

- Look for an existing PR: `gh pr view --json number,url,state,title,body`. (`gh pr create` is not idempotent — it errors if a PR already exists — so always branch on this check rather than blindly creating.)
- If an open PR exists, the push above already refreshed its commits. Re-derive the intended title/body from the current branch commits; if they have drifted from the PR's existing title/body, update them with `gh pr edit --title ... --body ...`. Report the URL.
- If none exists, create one: `gh pr create --base "$base"`. Derive a Conventional Commits–style title and a concise body from the branch commits (`git log "origin/$base..HEAD"`).

## Notes

- Keep the user in the loop on anything destructive: force-push and conflict resolution both need explicit confirmation.
- Respect repo conventions: if the project's AGENTS.md / CLAUDE.md forbids opening PRs, surface that and confirm before creating one.
