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
    (! type sheldon &>/dev/null 2>&1) &&
      brew install sheldon
    ;;
  *) exit 1;;
esac

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
ln -snfv "$DOTFILES_DIR"/.Brewfile ~/.Brewfile
ln -snfv "$DOTFILES_DIR"/.Brewfile.lock.json ~/.Brewfile.lock.json
ln -snfv "$DOTFILES_DIR"/.gitconfig ~/.gitconfig
ln -snfv "$DOTFILES_DIR"/.gitignore_global ~/.gitignore_global
mkdir -p ~/.sheldon
ln -snfv "$DOTFILES_DIR"/plugins.toml ~/.sheldon/plugins.toml
ln -snfv "$DOTFILES_DIR"/.tmux.conf ~/.tmux.conf
ln -snfv "$DOTFILES_DIR"/.tool-versions ~/.tool-versions
ln -snfv "$DOTFILES_DIR"/.vimrc ~/.vimrc
ln -snfv "$DOTFILES_DIR"/.zprofile ~/.zprofile
ln -snfv "$DOTFILES_DIR"/.zshrc ~/.zshrc
ln -snfv "$DOTFILES_DIR"/.zshrc_aliases_functions ~/.zshrc_aliases_functions

(! echo "$SHELL" | grep -q zsh) && chsh -s "$(which zsh)"
