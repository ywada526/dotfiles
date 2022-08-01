#!/bin/sh

# zinit
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --global

# fzf
"$(brew --prefix)"/opt/fzf/install

# anyenv
anyenv init

# link to dropbox
ln -snfv ~/dropbox/settings/.zsh_history ~/.zsh_history

mkdir -p ~/.config
ln -snfv ~/dropbox/settings/karabiner ~/.config/karabiner
