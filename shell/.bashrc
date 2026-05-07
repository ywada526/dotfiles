# shellcheck shell=bash
# Single entry point for bash: sourced by login shells via .bash_profile,
# by non-login interactive shells directly, and by non-interactive shells
# (scripts, `bash -c '...'`) via BASH_ENV (set in .zshenv).
#
# Do NOT add `[[ $- != *i* ]] && return` here — it would skip the hooks
# in non-interactive scripts, which is exactly the case BASH_ENV is
# meant to cover.
# shellcheck source=/dev/null
. "$HOME/dotfiles/security/hooks.sh"
