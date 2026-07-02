# shellcheck shell=bash
# Single entry point for bash: sourced by login shells via .bash_profile, by non-login interactive shells directly, and by non-interactive shells (scripts, `bash -c '...'`) via BASH_ENV (set in .zshenv).
#
# Keep package guards in non-interactive shells and after Safe Chain setup.
# shellcheck source=/dev/null
. "$HOME/.safe-chain/scripts/init-posix.sh"
# shellcheck source=/dev/null
. "$HOME/dotfiles/shell/package-guards.sh"
