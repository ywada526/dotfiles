## Terminal Theme

```sh
open ~/dotfiles/MyProfile.terminal
defaults write com.apple.terminal "Default Window Settings" -string "MyProfile"
defaults write com.apple.Terminal "Startup Window Settings" -string "MyProfile"
```

## Install Priority Apps

```sh
brew install ghq; brew install --cask 1password alfred docker google-chrome \
  google-japanese-ime karabiner-elements lunar slack visual-studio-code
```

## Link to Dropbox settings

### zsh history

```sh
ln -snfv ~/Library/CloudStorage/Dropbox/settings/zsh/.zsh_history ~/.zsh_history
```

### karabiner

```sh
mkdir -p ~/.config
ln -snfv ~/Library/CloudStorage/Dropbox/settings/karabiner ~/.config/karabiner
```

### Alfred

Preferences > Advanced > Set preferences folder...
`~/Library/CloudStorage/Dropbox/settings/alfred`

### iTerm

General > Preferences
`~/Library/CloudStorage/Dropbox/settings/iterm`

## Homebrew bundle

```sh
brew bundle --global
```

### Manual Install

- https://code.visualstudio.com/insiders/
- https://www.google.com/chrome/canary/
