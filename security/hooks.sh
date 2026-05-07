# shellcheck shell=bash
# Block / wrap package manager and task runner invocations across zsh and bash.
#
# Sourced from shell/.zshenv and shell/.bashrc / shell/.bash_profile,
# plus pointed to via BASH_ENV (set in .zshenv) so non-interactive bash
# (scripts, `bash -c '...'`, shebang scripts) also picks them up.
#
# Functions are used (not aliases) because bash does not expand aliases
# in non-interactive shells by default. Functions work in every variant
# of zsh and bash that sources this file.
#
# Two layers compose here:
#   - sfw-free  routes package manager network calls through Socket
#               Firewall. Free tier covers npm/pnpm/yarn/pip/uv/cargo;
#               bun is HTTP-proxy intercepted just fine in practice.
#   - envchain  injects per-repo secrets from macOS Keychain. The
#               namespace is derived from `git remote.origin.url` and
#               walked up toward owner/repo. Falls through silently
#               when no candidate matches a stored namespace.
#
# Bypass when intentional:
#   command pnpm ...                   — one-shot bypass (skips function lookup)
#   ~/.local/share/mise/shims/pnpm ... — explicit absolute path also bypasses

# --- Block: force pnpm ---
npm()      { printf 'npm is disabled — use pnpm instead.\n' >&2; return 1; }
npx()      { printf 'npx is disabled — use "pnpm dlx" (or "pnpm exec") instead.\n' >&2; return 1; }
yarn()     { printf 'yarn is disabled — use pnpm instead.\n' >&2; return 1; }
# corepack can re-enable yarn outside of mise's trust path, opening a
# back door around the rest of the controls here.
corepack() { printf 'corepack is disabled — pnpm is installed via mise.\n' >&2; return 1; }

# --- envchain helpers ---
# Resolve a namespace from the current dir's git remote, walking up the
# subpath toward owner/repo. Returns the most specific match found in
# `envchain --list`; fails when none of the candidates are defined.
_envchain_namespace() {
  local remote_url repo_root subpath candidate_namespace registered_namespaces
  remote_url=$(git config --get remote.origin.url 2>/dev/null) || return 1
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  subpath=${PWD#"$repo_root"}; subpath=${subpath#/}
  candidate_namespace=$(printf '%s' "$remote_url" | sed -E 's#(git@|https?://)[^:/]+[:/]##; s#\.git$##')
  [[ -n $subpath ]] && candidate_namespace="$candidate_namespace/$subpath"
  registered_namespaces=$(envchain --list 2>/dev/null) || return 1
  while :; do
    if printf '%s\n' "$registered_namespaces" | grep -qFx "$candidate_namespace"; then
      printf '%s\n' "$candidate_namespace"; return 0
    fi
    # Stop at owner/repo (one slash). Anything shallower is not a repo
    # identity in this scheme.
    [[ $candidate_namespace == */*/* ]] || return 1
    candidate_namespace=${candidate_namespace%/*}
  done
}

# Run "$@" with envchain prefix when a namespace matches the current
# dir; otherwise run via `command` to skip our function. Works for both
# "binary chain" cases (e.g. sfw-free pnpm ...) and direct binary cases
# (e.g. task ...) — `command <bin>` is a no-op pass-through for binaries
# that don't have function/alias overrides.
_envchain_run() {
  local namespace
  if namespace=$(_envchain_namespace); then
    envchain "$namespace" "$@"
  else
    command "$@"
  fi
}

# --- Wrap: sfw-free + envchain (run user scripts and need network) ---
pnpm() { _envchain_run sfw-free pnpm "$@"; }
bun()  { _envchain_run sfw-free bun  "$@"; }
nr()   { _envchain_run sfw-free nr   "$@"; }

# --- Wrap: sfw-free only (install / dlx style) ---
ni()    { sfw-free ni    "$@"; }
nci()   { sfw-free nci   "$@"; }
nup()   { sfw-free nup   "$@"; }
nlx()   { sfw-free nlx   "$@"; }
pip()   { sfw-free pip   "$@"; }
uv()    { sfw-free uv    "$@"; }
uvx()   { sfw-free uvx   "$@"; }
cargo() { sfw-free cargo "$@"; }

# --- Wrap: envchain only (task runners) ---
task() { _envchain_run task "$@"; }
make() { _envchain_run make "$@"; }
mise() { _envchain_run mise "$@"; }
