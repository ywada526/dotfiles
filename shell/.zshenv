# bash subshells: interactive non-login reads .bashrc, but non-interactive
# (scripts, `bash -c '...'`) only honors BASH_ENV. Point it at .bashrc so
# every bash entry point funnels through the same file.
export BASH_ENV="$HOME/.bashrc"

# Block / wrap package manager and task runner calls (force pnpm,
# sfw-free wrap, envchain wrap).
# Functions are not inherited across exec(), so .zshenv must redefine
# them for every zsh invocation (login, interactive, non-interactive,
# scripts). Heavier login-only setup (brew shellenv, PATH prepends)
# lives in .zprofile so subshells don't pay that cost.
. "$HOME/dotfiles/security/hooks.sh"
