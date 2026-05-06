[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

export XDG_CONFIG_HOME="$HOME/.config"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/mise/shims:$PATH"
export PATH="/Users/yuta.wada/.rd/bin:$PATH"

# bash subshells: interactive non-login reads .bashrc, but non-interactive
# (scripts, `bash -c '...'`) only honors BASH_ENV. Point it at .bashrc so
# every bash entry point funnels through the same file.
export BASH_ENV="$HOME/.bashrc"

# Block / wrap package manager calls (force pnpm, sfw-free wrap).
# Functions in blockers.sh take effect for every zsh invocation that sources
# .zshenv (login, interactive, non-interactive, scripts).
. "$HOME/dotfiles/security/blockers.sh"
