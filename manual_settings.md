## Terminal Theme

```sh
open ~/dotfiles/MyProfile.terminal
defaults write com.apple.terminal "Default Window Settings" -string "MyProfile"
defaults write com.apple.Terminal "Startup Window Settings" -string "MyProfile"
```

## Install Priority Apps

```sh
brew install ghq; brew install --cask 1password alfred docker dropbox google-chrome \
  iterm2 karabiner-elements lunar raycast slack visual-studio-code
```

## Link to Dropbox Settings

### Symbolic Link

```sh
DROPBOX_DIR="$(plutil -extract personal.path raw -expect string "$HOME/.dropbox/info.json")"

ln -snfv "$DROPBOX_DIR/settings/macnative/LocalDictionary" ~/Library/Spelling/LocalDictionary
ln -snfv "$DROPBOX_DIR/settings/zsh/.zsh_history" ~/.zsh_history
ln -snfv "$DROPBOX_DIR/settings/homebrew/.Brewfile" ~/.Brewfile
ln -snfv "$DROPBOX_DIR/settings/homebrew/.Brewfile.lock.json" ~/.Brewfile.lock.json
mkdir -p ~/.config/karabiner/assets
/bin/cp -f "$DROPBOX_DIR/settings/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
rsync -a --delete "$DROPBOX_DIR/settings/karabiner/assets/" "$HOME/.config/karabiner/assets/"

```

### Raycast

Script Commands > Add Directories
`$DROPBOX_DIR/settings/raycast/script-commands`

### Alfred

Preferences > Advanced > Set preferences folder...
`$DROPBOX_DIR/settings/alfred`

### iTerm

General > Settings
`$DROPBOX_DIR/settings/iterm`
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
