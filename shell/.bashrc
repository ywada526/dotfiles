# shellcheck shell=bash
# Single entry point for bash: sourced by login shells via .bash_profile, by non-login interactive shells directly, and by non-interactive shells (scripts, `bash -c '...'`) via BASH_ENV (set in .zshenv).
#
# Keep Safe Chain active in non-interactive shells.
# shellcheck source=/dev/null
. "$HOME/.safe-chain/scripts/init-posix.sh"
