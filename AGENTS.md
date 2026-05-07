# Repository Guidelines

## Project Structure & Module Organization
This repository manages personal dotfiles and local tool configuration, not an application codebase. Configs are grouped by tool into per-tool subdirectories (`zsh/`, `git/`, `tmux/`, `vim/`, `mise/`, `codex/`, `bun/`, `pnpm/`, `claude/`, `security/`); files inside keep their dot-prefixed destination names (e.g. `zsh/.zshrc`, `git/.gitconfig`). [`install.sh`](/Users/ywada526/dotfiles/install.sh) symlinks each into `$HOME` or `~/.config`. [`zsh/plugins.toml`](/Users/ywada526/dotfiles/zsh/plugins.toml) defines Sheldon-managed Zsh plugins. [`setup.md`](/Users/ywada526/dotfiles/setup.md) documents post-install macOS setup and links into Dropbox-managed settings. [`README.md`](/Users/ywada526/dotfiles/README.md) stays intentionally minimal and only covers bootstrap installation.

## Working Principles
Prefer small, tool-focused edits. Keep existing file layout and naming intact unless there is a clear maintenance benefit to changing them. This repo contains machine setup entrypoints, so avoid broad refactors that make local recovery harder. When updating shell or TOML config, preserve the surrounding style instead of normalizing unrelated sections.

Do not commit secrets, local tokens, or values copied from the private companion repository referenced in [`setup.md`](/Users/ywada526/dotfiles/setup.md). Treat Dropbox-backed files such as `~/Library/CloudStorage/Dropbox/settings/...` as external state: document required manual steps, but do not silently vendor their contents into this repository.

## Build, Test, and Development Commands
Run commands from the repository root unless a file explicitly requires otherwise.

- `./install.sh`: installs base dependencies and recreates symlinks for managed dotfiles under `$HOME` and `~/.config`.
- `bash -n install.sh`: syntax-check the installer.
- `source ~/.zshrc`: reload Zsh config after editing shell startup files.
- `sheldon lock --update && sheldon source`: validate plugin changes in [`zsh/plugins.toml`](/Users/ywada526/dotfiles/zsh/plugins.toml) when Sheldon behavior is affected.

Avoid running `./install.sh` on the host machine as a casual verification step unless the task specifically requires installer validation, because it rewrites live symlinks and can change the current shell environment.

## Coding Style & Naming Conventions
Shell scripts should use `#!/usr/bin/env bash`. New or substantially edited shell scripts should prefer `set -euo pipefail`; existing files may use slightly different strict-mode flags, and those should only be normalized when the change is directly relevant. Match the current formatting style in each file: shell scripts generally use two-space indentation.

Write comments in English, even when chatting with the user in Japanese. Keep them short and operational. Favor descriptive lowercase filenames. When adding config for a tool, place it next to the rest of that tool's files rather than introducing a new top-level location.

## Testing Guidelines
There is no automated test suite, so validate changes with focused checks tied to the edited files.

- Shell scripts: run `bash -n` and `shellcheck`, and if behavior changed, execute the narrowest safe command path. shellcheck targets bash/sh only — zsh files (`.zshrc`, `.zshenv`) are not analyzed. Prefer `# shellcheck source=/dev/null` to opt out of following sourced files rather than enabling `external-sources` globally.
- Zsh config: run `source ~/.zshrc` and verify startup in a fresh shell.
- Installer changes: test `./install.sh` only in a disposable environment, container, or otherwise reversible setup.
- Manual setup docs: confirm paths, commands, and filenames against the current repository layout.

## Commit & Collaboration Guidelines
Keep commits scoped to one tool, workflow, or setup concern. This repository is maintained directly on `main`; do not prepare pull requests unless the owner explicitly asks for one. Agents should stop after local edits or local commits and must not push. The repository owner handles any push to `main` manually.

Because this repo is often applied directly to a live workstation, call out any change that is destructive, machine-specific, or likely to affect login shells, window management, or globally installed tooling.
