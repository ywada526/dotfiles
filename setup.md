## macOS System Defaults

Declared in [`mise.toml`](mise.toml). Run from the repository root:

```sh
mise bootstrap --only macos-defaults
```

`--only macos-defaults` is what runs the `post-defaults` hook, which handles the
two things the declarative section can't: the `defaults -currentHost` write, and
flushing cfprefsd before restarting Dock and Finder. `mise bootstrap macos
defaults apply` writes the defaults but skips hooks.

To see drift against the current machine without changing anything:

```sh
mise bootstrap macos defaults status
```

## Install Priority Apps

```sh
brew install ghq
brew install --cask 1password dropbox google-chrome karabiner-elements raycast slack visual-studio-code
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
  mkdir -p ~/.config
  rsync -a --delete "$HOME/Library/CloudStorage/Dropbox/settings/karabiner/" "$HOME/.config/karabiner/"
fi
```

### Raycast

Script Commands > Add Directories
`~/Library/CloudStorage/Dropbox/settings/raycast/script-commands`

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

```sh
ghq get ywada526/dotfiles.local
```
