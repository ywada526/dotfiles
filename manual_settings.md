## macOS System Defaults

```sh
# Trackpad: tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: three finger drag (may require logout/reboot to take effect)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Trackpad: tracking speed (max = 3.0)
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3.0

# Trackpad: click pressure (0 = Light, 1 = Medium, 2 = Firm)
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad FirstClickThreshold -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad SecondClickThreshold -int 0

# Keyboard: key repeat rate / initial delay (UI slider max: fastest / shortest)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Keyboard: disable press-and-hold accent popup (prefer key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Keyboard: enable full keyboard navigation (Tab to move focus between all controls)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Finder: default to list view (Nlsv = list, icnv = icon, clmv = column, Flwv = gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder: show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show path bar (breadcrumbs) at the bottom
defaults write com.apple.finder ShowPathbar -bool true

killall Finder >/dev/null 2>&1 || true

# Dock: auto-hide, and effectively disable re-appearing on hover
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 1000
defaults write com.apple.dock autohide-time-modifier -float 0
killall Dock >/dev/null 2>&1 || true

# Animations: kill window open/close fade and shrink resize transition to instant
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
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
