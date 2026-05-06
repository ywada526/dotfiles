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
corepack() { printf 'corepack is disabled — pnpm is installed via mise.\n' >&2; return 1; }

# --- Wrap: route package manager invocations through Socket Firewall ---
# Free tier covers npm/pnpm/yarn/pip/uv/cargo. Go and Ruby are not covered.
pnpm()  { sfw-free pnpm  "$@"; }
pip()   { sfw-free pip   "$@"; }
uv()    { sfw-free uv    "$@"; }
uvx()   { sfw-free uvx   "$@"; }
cargo() { sfw-free cargo "$@"; }
