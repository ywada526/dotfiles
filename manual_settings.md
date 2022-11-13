## Terminal Theme

```sh
open ~/dotfiles/MyProfile.terminal
defaults write com.apple.terminal "Default Window Settings" -string "MyProfile"
defaults write com.apple.Terminal "Startup Window Settings" -string "MyProfile"
```

## Install Priority Apps

```sh
brew install ghq; brew install --cask 1password alfred docker google-chrome \
  google-drive google-japanese-ime karabiner-elements lunar slack visual-studio-code
```

## Link to Dropbox settings

### zsh history

```sh
ln -snfv ~/Dropbox/settings/zsh/.zsh_history ~/.zsh_history
```

### karabiner

```sh
mkdir -p ~/.config
ln -snfv ~/Dropbox/settings/karabiner ~/.config/karabiner
```

### Alfred

Preferences > Advanced > Set preferences folder...
`~/Dropbox/settings/alfred`

## Homebrew bundle

```sh
brew bundle --global
```

### Install Visual Studio Code Insiders

https://code.visualstudio.com/insiders/