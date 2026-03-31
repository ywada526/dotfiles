# Repository Guidelines

## Project Structure & Module Organization
This repository manages personal dotfiles and local tool configuration, not an application codebase. Top-level files such as `.zshrc`, `.zprofile`, `.zshrc_aliases_functions`, `.vimrc`, `.gitconfig`, `.tmux.conf`, `.mise.toml`, `.jj-config.toml`, `.npmrc`, and `.bunfig.toml` are symlinked into `$HOME` or `~/.config` by [`install.sh`](/Users/ywada526/dotfiles/install.sh). [`aerospace/`](/Users/ywada526/dotfiles/aerospace) contains the AeroSpace config and helper layout scripts. [`plugins.toml`](/Users/ywada526/dotfiles/plugins.toml) defines Sheldon-managed Zsh plugins. [`manual_settings.md`](/Users/ywada526/dotfiles/manual_settings.md) documents post-install macOS setup and links into Dropbox-managed settings. [`README.md`](/Users/ywada526/dotfiles/README.md) stays intentionally minimal and only covers bootstrap installation.

## Working Principles
Prefer small, tool-focused edits. Keep existing file layout and naming intact unless there is a clear maintenance benefit to changing them. This repo contains machine setup entrypoints, so avoid broad refactors that make local recovery harder. When updating shell or TOML config, preserve the surrounding style instead of normalizing unrelated sections.

Do not commit secrets, local tokens, or values copied from the private companion repository referenced in [`manual_settings.md`](/Users/ywada526/dotfiles/manual_settings.md). Treat Dropbox-backed files such as `~/Library/CloudStorage/Dropbox/settings/...` as external state: document required manual steps, but do not silently vendor their contents into this repository.

## Build, Test, and Development Commands
Run commands from the repository root unless a file explicitly requires otherwise.

- `./install.sh`: installs base dependencies and recreates symlinks for managed dotfiles under `$HOME` and `~/.config`.
- `bash -n install.sh aerospace/*.sh`: syntax-check the installer and AeroSpace helper scripts.
- `source ~/.zshrc`: reload Zsh config after editing shell startup files.
- `aerospace reload-config`: reload [`aerospace/aerospace.toml`](/Users/ywada526/dotfiles/aerospace/aerospace.toml) after AeroSpace changes.
- `sheldon lock --update && sheldon source`: validate plugin changes in [`plugins.toml`](/Users/ywada526/dotfiles/plugins.toml) when Sheldon behavior is affected.

Avoid running `./install.sh` on the host machine as a casual verification step unless the task specifically requires installer validation, because it rewrites live symlinks and can change the current shell environment.

## Coding Style & Naming Conventions
Shell scripts should use `#!/usr/bin/env bash`. New or substantially edited shell scripts should prefer `set -euo pipefail`; existing files may use slightly different strict-mode flags, and those should only be normalized when the change is directly relevant. Match the current formatting style in each file: shell scripts generally use two-space indentation, while [`aerospace/aerospace.toml`](/Users/ywada526/dotfiles/aerospace/aerospace.toml) uses aligned TOML blocks.

Keep comments short and operational. Favor descriptive lowercase filenames such as `layout-3columns.sh`. When adding config for a tool, place it next to the rest of that tool's files rather than introducing a new top-level location.

## Testing Guidelines
There is no automated test suite, so validate changes with focused checks tied to the edited files.

- Shell scripts: run `bash -n` and, if behavior changed, execute the narrowest safe command path.
- Zsh config: run `source ~/.zshrc` and verify startup in a fresh shell.
- AeroSpace config or scripts: run `aerospace reload-config` and exercise the affected key bindings or layout script manually.
- Installer changes: test `./install.sh` only in a disposable environment, container, or otherwise reversible setup.
- Manual setup docs: confirm paths, commands, and filenames against the current repository layout.

## Commit & Collaboration Guidelines
Keep commits scoped to one tool, workflow, or setup concern. This repository is maintained directly on `main`; do not prepare pull requests unless the owner explicitly asks for one. Agents should stop after local edits or local commits and must not push. The repository owner handles any push to `main` manually.

Because this repo is often applied directly to a live workstation, call out any change that is destructive, machine-specific, or likely to affect login shells, window management, or globally installed tooling.
