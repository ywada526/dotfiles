# zinit
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --global

# anyenv
anyenv init

# link to dropbox
ln -snfv $HOME/dropbox/settings/.zsh_history $HOME/.zsh_history

mkdir -p $HOME/.config
ln -snfv $HOME/dropbox/settings/karabiner $HOME/.config/karabiner

