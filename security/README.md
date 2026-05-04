# security/

Cross-cutting security tooling that isn't ecosystem-specific (compare with
`pnpm/` which is all about pnpm).

## git-hooks/

Globally-applied git hooks via `core.hooksPath`. Set in `install.sh`:

```bash
git config --global core.hooksPath "$DOTFILES_DIR/security/git-hooks"
```

### pre-commit

Runs `gitleaks protect --staged` before every commit to block secret leakage
(API keys, tokens, private keys, etc.).

**Bypass when needed:** `git commit --no-verify`. Use sparingly.

**Caveat:** repos that set their own `core.hooksPath` (husky / lefthook /
pre-commit framework) take precedence. The global hook will not run there —
add gitleaks to those repos' hook config separately.

## Out of scope

Periodic / forensic scanning (trufflehog, OSV-scanner, Trivy filesystem
audits) lives in a separate repo. See the project memory for context.
