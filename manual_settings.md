## Terminal Theme

```sh
open ~/dotfiles/MyProfile.terminal
defaults write com.apple.terminal "Default Window Settings" -string "MyProfile"
defaults write com.apple.Terminal "Startup Window Settings" -string "MyProfile"
```

## Install Priority Apps

```sh
brew install ghq; brew install --cask 1password alfred docker dropbox google-chrome \
  google-japanese-ime karabiner-elements lunar slack visual-studio-code
```

## Link to Dropbox Settings

### Symbolic Link

```sh
ln -snfv ~/Dropbox/settings/macnative/LocalDictionary ~/Library/Spelling/LocalDictionary
ln -snfv ~/Dropbox/settings/zsh/.zsh_history ~/.zsh_history
ln -snfv ~/Dropbox/settings/homebrew/Brewfile ~/.Brewfile
ln -snfv ~/Dropbox/settings/homebrew/Brewfile.lock.json ~/.Brewfile.lock.json
dir -p ~/.config
ln -snfv ~/Dropbox/settings/karabiner ~/.config/karabiner
ln -snfv ~/Dropbox/settings/raycast/script-commands ~/ghq/github.com/raycast/script-commands
```

### Alfred

Preferences > Advanced > Set preferences folder...
`~/Dropbox/settings/alfred`

### iTerm

General > Preferences
`~/Dropbox/settings/iterm`
Save changes Automatically

## Homebrew bundle

```sh
brew bundle --global
```

## Manual Install

- https://code.visualstudio.com/insiders/
- https://www.google.com/chrome/canary/
- https://www.homerow.app/

## Private Settings

https://github.com/ywada526/dotfiles-private
