# security/

Cross-cutting security tooling that isn't ecosystem-specific (compare with
`pkg/` which holds package-manager-specific config).

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

## envchain (secrets management)

Installed via `brew install envchain` from `install.sh`. Stores secrets in
the macOS Keychain and injects them into a child process's environment for
the duration of one command.

### Usage pattern

```bash
# One-time: store secrets for a project namespace
envchain --set myproject DB_PASSWORD API_KEY

# Run a command with those secrets in env
envchain myproject pnpm dev
```

### Why envchain over plain .env or shell-export

- Secrets at-rest live in Keychain (encrypted), not in plaintext files
- Keychain ACLs prompt on third-party reads (`security find-generic-password`
  from random processes triggers a macOS dialog)
- Injection is **per-command scope**: env vars only exist while the wrapped
  command runs, not in the parent shell. Postinstall malware running in an
  unrelated `pnpm install` can't see them.

### Per-project transparent wrapping (pattern, not yet automated)

To make `pnpm dev` transparently use envchain inside a project:

1. Add `bin.local/` to `.gitignore` (per-user, not committed)
2. Symlink wrapper scripts in `bin.local/` for each command (`pnpm`, `task`, etc.)
3. Add `mise.local.toml` (also gitignored) with `[env] _.path = ["./bin.local"]`

This gets `pnpm dev` invoked as `envchain <ns> pnpm dev` automatically inside
the project. AGENTS.md / CLAUDE.md stay clean (canonical commands).

A generic dispatcher script for this is intentionally **not** in dotfiles
yet — pending decision on whether to standardize the pattern.

## AI agent / MCP server hygiene

Operational notes (no automated dotfiles enforcement, just reminders).

### MCP server adoption checklist

Before adding an MCP server (Claude Code plugin, Codex `mcp_servers.*`,
Cursor / Cline, etc.):

- Is the server published by an official source (Anthropic, the SaaS owner,
  a reputable individual)? Random repos warrant extra scrutiny.
- What credentials does it consume? Use scoped / short-lived tokens
  (e.g. fine-grained GitHub PATs, read-only Slack tokens).
- How is it installed? `npx -y` is blocked here by design — prefer `pnpm
  dlx` (which inherits cooldown) or pin the package via `npm:` in
  `.mise.toml` for a fully version-controlled binary.
- Codex example: see `.codex-config.toml` for the `pnpm dlx` pattern.

## audit/

Composable supply-chain audit scripts. `scan.sh` runs Trivy +
OSV-Scanner against one path and emits combined JSON; `scan-all.sh`
iterates over a gitignored `targets` file. Compose with whatever
runs on top — cron, CI, scheduled agent. See
[`audit/README.md`](audit/README.md).

## Out of scope

Forensic / one-off scanning (trufflehog history sweeps, YARA-based
analysis) — done ad-hoc, not wired into this directory.
