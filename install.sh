#!/usr/bin/env bash

set -eux

case $(uname) in
  "Linux" )
    [ "$(grep ^ID /etc/os-release)" != "ID=debian" ] && exit 1

    apt update && apt -y install curl git less vim zsh
    (! type sheldon &>/dev/null 2>&1) &&
      curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    ;;
  "Darwin" )
    (! type brew &>/dev/null 2>&1) &&
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    (! type sheldon &>/dev/null 2>&1) &&
      brew install sheldon
    ;;
  *) exit 1;;
esac

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
ln -snfv "$DOTFILES_DIR"/.gitconfig ~/.gitconfig
ln -snfv "$DOTFILES_DIR"/.gitignore_global ~/.gitignore_global
mkdir -p ~/.config/sheldon
ln -snfv "$DOTFILES_DIR"/plugins.toml ~/.config/sheldon/plugins.toml
ln -snfv "$DOTFILES_DIR"/.tmux.conf ~/.tmux.conf
ln -snfv "$DOTFILES_DIR"/.mise.toml ~/.mise.toml
ln -snfv "$DOTFILES_DIR"/.vimrc ~/.vimrc
ln -snfv "$DOTFILES_DIR"/.zprofile ~/.zprofile
ln -snfv "$DOTFILES_DIR"/.zshrc ~/.zshrc
ln -snfv "$DOTFILES_DIR"/.zshrc_aliases_functions ~/.zshrc_aliases_functions
ln -snfv "$DOTFILES_DIR"/.npmrc ~/.npmrc
ln -snfv "$DOTFILES_DIR"/.bunfig.toml ~/.bunfig.toml

(! echo "$SHELL" | grep -q zsh) && chsh -s "$(which zsh)"
