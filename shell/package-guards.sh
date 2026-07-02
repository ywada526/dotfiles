# shellcheck shell=bash
# Package manager policy guard shared by zsh and bash startup files.

npm()      { printf 'npm is disabled; use pnpm instead.\n' >&2; return 1; }
npx()      { printf 'npx is disabled; use "pnpm dlx" or "pnpm exec" instead.\n' >&2; return 1; }
yarn()     { printf 'yarn is disabled; use pnpm instead.\n' >&2; return 1; }
corepack() { printf 'corepack is disabled; pnpm is installed via mise.\n' >&2; return 1; }
