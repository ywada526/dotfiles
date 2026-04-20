## Terminal Theme

```sh
open ~/dotfiles/MyProfile.terminal
defaults write com.apple.terminal "Default Window Settings" -string "MyProfile"
defaults write com.apple.Terminal "Startup Window Settings" -string "MyProfile"
```

## Install Priority Apps

```sh
brew install ghq; brew install --cask 1password docker dropbox google-chrome \
  iterm2 karabiner-elements raycast slack visual-studio-code
```

## Link to Dropbox Settings

Make the `settings/` folder available offline in Dropbox before running the script below. Otherwise `rsync` will hang waiting for File Provider to download on-demand files.

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
  mkdir -p ~/.config
  rsync -a --delete "$HOME/Library/CloudStorage/Dropbox/settings/karabiner/" "$HOME/.config/karabiner/"
fi
```

### Raycast

Script Commands > Add Directories
`~/Library/CloudStorage/Dropbox/settings/raycast/script-commands`

### iTerm

General > Settings
`~/Library/CloudStorage/Dropbox/settings/iterm`
Save changes Automatically

## Default App: VS Code for Text Files

```sh
brew install duti
for ext in .md .txt .json .jsonc .yaml .yml .toml .ts .tsx .js .jsx .mjs .cjs .css .scss .xml .csv .log .sh .zsh .bash .py .rb .go .rs .conf .ini .env; do
  duti -s com.microsoft.VSCode "$ext" all
done
```

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
