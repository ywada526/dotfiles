#!/bin/sh

DOTFILES_PATH="$HOME/dotfiles"
ln -snfv $DOTFILES_PATH/.Brewfile $HOME/.Brewfile
ln -snfv $DOTFILES_PATH/.gitconfig $HOME/.gitconfig
ln -snfv $DOTFILES_PATH/.gitignore_global $HOME/.gitignore_global
ln -snfv $DOTFILES_PATH/.tmux.conf $HOME/.tmux.conf
ln -snfv $DOTFILES_PATH/.zprofile $HOME/.zprofile
ln -snfv $DOTFILES_PATH/.zshrc $HOME/.zshrc
