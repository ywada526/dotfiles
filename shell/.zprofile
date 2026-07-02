# Login-shell-only setup. Runs once per terminal session; child shells
# inherit the resulting environment via env vars, so non-interactive
# `zsh -c '...'` subshells skip these costs entirely.
#
# Anything that spawns a subprocess (brew Ruby) or unconditionally
# prepends to PATH belongs here, not in .zshenv where it would re-run
# for every subshell.

export XDG_CONFIG_HOME="$HOME/.config"

[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

path=(
  "$HOME/.safe-chain/shims"
  "$HOME/.safe-chain/bin"
  "$HOME/.local/bin"
  "$HOME/.local/share/mise/shims"
  $path
)
export PATH
