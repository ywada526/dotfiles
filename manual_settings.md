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
EXPECTED_DROPBOX_DIR="$HOME/Library/CloudStorage/Dropbox"
if [ "${DROPBOX_DIR%/}" != "${EXPECTED_DROPBOX_DIR%/}" ]; then
  printf '%s\n' 'Dropbox File Provider is disabled. Enable Dropbox on File Provider. See https://help.dropbox.com/installs/dropbox-for-macos-support' >&2
  false
else
  ln -snfv "$HOME/Library/CloudStorage/Dropbox/settings/macnative/LocalDictionary" ~/Library/Spelling/LocalDictionary
  ln -snfv "$HOME/Library/CloudStorage/Dropbox/settings/zsh/.zsh_history" ~/.zsh_history
  ln -snfv "$HOME/Library/CloudStorage/Dropbox/settings/homebrew/.Brewfile" ~/.Brewfile
  ln -snfv "$HOME/Library/CloudStorage/Dropbox/settings/homebrew/.Brewfile.lock.json" ~/.Brewfile.lock.json
  mkdir -p ~/.config/karabiner/assets
  /bin/cp -f "$HOME/Library/CloudStorage/Dropbox/settings/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
  rsync -a --delete "$HOME/Library/CloudStorage/Dropbox/settings/karabiner/assets/" "$HOME/.config/karabiner/assets/"
fi

```

### Raycast

Script Commands > Add Directories
`~/Library/CloudStorage/Dropbox/settings/raycast/script-commands`

### Alfred

Preferences > Advanced > Set preferences folder...
`~/Library/CloudStorage/Dropbox/settings/alfred`

### iTerm

General > Settings
`~/Library/CloudStorage/Dropbox/settings/iterm`
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

https://github.com/ywada526/dotfiles.local
