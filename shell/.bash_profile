# Login shells: delegate to .bashrc so all bash entry points (login,
# non-login, non-interactive via BASH_ENV) funnel through one file.
[ -f ~/.bashrc ] && . ~/.bashrc
