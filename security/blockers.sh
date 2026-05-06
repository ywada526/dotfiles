# shellcheck shell=bash
# Block / wrap package manager invocations across zsh and bash.
#
# Sourced from shell/.zshenv and shell/.bashrc / shell/.bash_profile,
# plus pointed to via BASH_ENV (set in .zshenv) so non-interactive bash
# (scripts, `bash -c '...'`, shebang scripts) also picks them up.
#
# Functions are used (not aliases) because bash does not expand aliases
# in non-interactive shells by default. Functions work in every variant
# of zsh and bash that sources this file.
#
# Bypass when intentional:
#   command npm ...           — one-shot bypass (skips function lookup)
#   /opt/homebrew/bin/npm ... — explicit absolute path also bypasses

# --- Block: force pnpm ---
npm()      { printf 'npm is disabled — use pnpm instead.\n' >&2; return 1; }
npx()      { printf 'npx is disabled — use "pnpm dlx" (or "pnpm exec") instead.\n' >&2; return 1; }
# corepack can re-enable yarn outside of mise's trust path, opening a
# back door around the rest of the controls here.
corepack() { printf 'corepack is disabled — pnpm is installed via mise.\n' >&2; return 1; }

# --- Wrap (route package manager invocations through Socket Firewall) ---
# sfw-free Free tier covers npm/pnpm/yarn/pip/uv/cargo. Bun isn't on the
# explicit list but is HTTP-proxy intercepted just fine in practice.
pnpm()  { sfw-free pnpm  "$@"; }
bun()   { sfw-free bun   "$@"; }
pip()   { sfw-free pip   "$@"; }
uv()    { sfw-free uv    "$@"; }
uvx()   { sfw-free uvx   "$@"; }
cargo() { sfw-free cargo "$@"; }
