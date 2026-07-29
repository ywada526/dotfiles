#!/usr/bin/env bash

set -euo pipefail

case $(uname) in
  "Linux" )
    ! grep -qE '^ID=(debian|ubuntu)' /etc/os-release && exit 1

    sudo apt update && sudo apt -y install curl git less vim zsh
    (! type sheldon &>/dev/null 2>&1) &&
      curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | sudo bash -s -- --repo rossmacarthur/sheldon --to /usr/local/bin
    (! type mise &>/dev/null 2>&1) &&
      curl --proto '=https' -fLsS https://mise.run \
        | sudo MISE_INSTALL_PATH=/usr/local/bin/mise sh
    ;;
  "Darwin" )
    if ! type brew &>/dev/null 2>&1; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    # Not guarded by the block above: an existing Homebrew does not imply these
    # are installed, and mise is required for the bootstrap step below.
    brew install sheldon mise fzf zoxide carapace
    ;;
  *) exit 1;;
esac

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

# Symlinks are declared in [dotfiles] in mise.toml. `--only dotfiles` skips the
# rest of the bootstrap sequence, which stays opt-in via a bare `mise bootstrap`.
mise trust "$DOTFILES_DIR"
mise -C "$DOTFILES_DIR" bootstrap --only dotfiles --yes

# Local / private overrides (optional)
DOTFILES_LOCAL_DIR="${DOTFILES_LOCAL_DIR:-$HOME/ghq/github.com/ywada526/dotfiles.local}"
if [ -x "$DOTFILES_LOCAL_DIR/install.sh" ]; then
  "$DOTFILES_LOCAL_DIR/install.sh"
fi

if [ -z "${REMOTE_CONTAINERS:-}" ] && ! echo "${SHELL:-}" | grep -q zsh; then
  chsh -s "$(which zsh)"
fi
