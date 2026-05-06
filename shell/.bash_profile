# shellcheck shell=bash
# Login shells: delegate to .bashrc so all bash entry points (login,
# non-login, non-interactive via BASH_ENV) funnel through one file.
# shellcheck source=/dev/null
[ -f ~/.bashrc ] && . ~/.bashrc
