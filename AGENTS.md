# Repository Guidelines

## Project Structure & Module Organization
This repository stores personal shell and tool configuration rather than application source code. Top-level dotfiles such as `.zshrc`, `.zprofile`, `.vimrc`, `.gitconfig`, and `.tmux.conf` are the primary managed assets. [`aerospace/`](/Users/ywada526/dotfiles/aerospace) contains AeroSpace window-manager scripts and `aerospace.toml`. [`install`](/Users/ywada526/dotfiles/install) bootstraps symlinks and core dependencies. [`plugins.toml`](/Users/ywada526/dotfiles/plugins.toml) manages Zsh plugins through Sheldon, and [`manual_settings.md`](/Users/ywada526/dotfiles/manual_settings.md) captures post-install manual steps for macOS.

## Build, Test, and Development Commands
Use these commands from the repository root:

- `./install`: installs required packages and symlinks repo files into `$HOME` and `~/.config`.
- `bash -n install aerospace/layout-1column.sh aerospace/layout-2columns.sh aerospace/layout-3columns.sh`: syntax-check shell scripts before committing.
- `source ~/.zshrc`: reload shell changes after updating Zsh-related files.
- `aerospace reload-config`: apply changes to [`aerospace/aerospace.toml`](/Users/ywada526/dotfiles/aerospace/aerospace.toml) without restarting the app.

## Coding Style & Naming Conventions
Shell scripts should use `#!/usr/bin/env bash` and `set -euo pipefail`, matching the existing scripts. Prefer two-space indentation in shell conditionals and TOML blocks, and keep inline comments short and functional. Use lowercase, descriptive filenames for scripts (`layout-3columns.sh`) and keep related config near the tool it configures, for example `aerospace/` for AeroSpace assets.

## Testing Guidelines
There is no automated test suite yet. Validate changes with targeted checks: run `bash -n` for edited shell scripts, reload the relevant tool (`source ~/.zshrc`, `aerospace reload-config`), and verify behavior manually in a fresh shell or workspace. When changing installer behavior, test `./install` in a disposable environment or container before committing.

## Commit & Pull Request Guidelines
Keep commits focused on one tool or workflow change. This repository is updated by committing directly on `main`; do not prepare pull requests. Agents should stop after local commits and must not push to `main`; pushes are performed manually by the repository owner after review.

## Security & Configuration Tips
Do not commit secrets, machine-specific tokens, or private config from the separate private settings repository. Keep personal overrides outside this repo when they should not be shared, and document any required manual linking steps in [`manual_settings.md`](/Users/ywada526/dotfiles/manual_settings.md).
