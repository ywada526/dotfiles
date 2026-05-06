#!/usr/bin/env bash

set -eux

case $(uname) in
  "Linux" )
    ! grep -qE '^ID=(debian|ubuntu)' /etc/os-release && exit 1

    sudo apt update && sudo apt -y install curl git less vim zsh git-delta
    (! type sheldon &>/dev/null 2>&1) &&
      curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | sudo bash -s -- --repo rossmacarthur/sheldon --to /usr/local/bin
    ;;
  "Darwin" )
    (! type brew &>/dev/null 2>&1) &&
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    (! type sheldon &>/dev/null 2>&1) &&
      brew install sheldon
    (! type envchain &>/dev/null 2>&1) &&
      brew install envchain
    ;;
  *) exit 1;;
esac

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
ln -snfv "$DOTFILES_DIR"/git/.gitconfig ~/.gitconfig
ln -snfv "$DOTFILES_DIR"/git/.gitignore_global ~/.gitignore_global
mkdir -p ~/.config/sheldon
ln -snfv "$DOTFILES_DIR"/shell/plugins.toml ~/.config/sheldon/plugins.toml
ln -snfv "$DOTFILES_DIR"/tmux/.tmux.conf ~/.tmux.conf
mkdir -p ~/.config/mise
ln -snfv "$DOTFILES_DIR"/mise/.mise.toml ~/.config/mise/config.toml
ln -snfv "$DOTFILES_DIR"/vim/.vimrc ~/.vimrc
ln -snfv "$DOTFILES_DIR"/shell/.zshenv ~/.zshenv
ln -snfv "$DOTFILES_DIR"/shell/.zshrc ~/.zshrc
ln -snfv "$DOTFILES_DIR"/shell/.bashrc ~/.bashrc
ln -snfv "$DOTFILES_DIR"/shell/.bash_profile ~/.bash_profile
ln -snfv "$DOTFILES_DIR"/pnpm/.npmrc ~/.npmrc
ln -snfv "$DOTFILES_DIR"/bun/.bunfig.toml ~/.bunfig.toml
mkdir -p ~/.codex
ln -snfv "$DOTFILES_DIR"/codex/.codex-config.toml ~/.codex/config.toml
mkdir -p ~/.claude
ln -snfv "$DOTFILES_DIR"/claude/CLAUDE.md ~/.claude/CLAUDE.md

# Install Claude Code natively (auto-updates)
(! type claude &>/dev/null 2>&1) &&
  curl -fsSL https://claude.ai/install.sh | bash

# Local / private overrides (optional)
DOTFILES_LOCAL_DIR="${DOTFILES_LOCAL_DIR:-$HOME/ghq/github.com/ywada526/dotfiles.local}"
if [ -x "$DOTFILES_LOCAL_DIR/install.sh" ]; then
  "$DOTFILES_LOCAL_DIR/install.sh"
fi

if [ -z "${REMOTE_CONTAINERS:-}" ] && ! echo "$SHELL" | grep -q zsh; then
  chsh -s "$(which zsh)"
fi
