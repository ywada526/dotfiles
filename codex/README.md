# Codex

This directory stores Codex files that are safe to share through dotfiles.

`~/.codex/config.toml` is intentionally not managed here. Codex writes local state into that file, such as trusted project paths and plugin marketplace metadata, so syncing it would make the dotfiles repository noisy and machine-specific.

Managed files:

- `AGENTS.md`: global Codex instructions.
- `rules/default.rules`: user-level command approval rules.
