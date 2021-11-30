#!/bin/sh

set -eux

DOTFILES_DIR=$(dirname "$0")
ln -snfv "$DOTFILES_DIR"/Brewfile ~/Brewfile
ln -snfv "$DOTFILES_DIR"/.gitconfig ~/.gitconfig
ln -snfv "$DOTFILES_DIR"/.gitignore_global ~/.gitignore_global
ln -snfv "$DOTFILES_DIR"/.tmux.conf ~/.tmux.conf
ln -snfv "$DOTFILES_DIR"/.vimrc ~/.vimrc
ln -snfv "$DOTFILES_DIR"/.zprofile ~/.zprofile
ln -snfv "$DOTFILES_DIR"/.zshrc ~/.zshrc

case $(uname) in
  "Linux" )
    apt-get update
    apt-get install fzf less zsh -y
    ;;
  "Darwin" )
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle --global
    "$(brew --prefix)"/opt/fzf/install
    ;;
esac

git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/
