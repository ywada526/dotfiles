#!/bin/sh

set -eux

DOTFILES_DIR=$(cd "$(dirname "$0")"; pwd)
ln -snfv "$DOTFILES_DIR"/.Brewfile ~/.Brewfile
ln -snfv "$DOTFILES_DIR"/.Brewfile.lock.json ~/.Brewfile.lock.json
ln -snfv "$DOTFILES_DIR"/.gitconfig ~/.gitconfig
ln -snfv "$DOTFILES_DIR"/.gitignore_global ~/.gitignore_global
ln -snfv "$DOTFILES_DIR"/.hyper.js ~/.hyper.js
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
    open ~/dotfiles/MyProfile.terminal
    defaults write com.apple.terminal "Default Window Settings" -string "MyProfile"
    defaults write com.apple.Terminal "Startup Window Settings" -string "MyProfile"
    if ! which brew; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew bundle --global
    # "$(brew --prefix)"/opt/fzf/install
    ;;
esac

if ! which zinit; then
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/
fi
