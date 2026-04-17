#!/usr/bin/env bash

set -eux

case $(uname) in
  "Linux" )
    ! grep -qE '^ID=(debian|ubuntu)' /etc/os-release && exit 1

    sudo apt update && sudo apt -y install curl git less vim zsh git-delta
    (! type sheldon &>/dev/null 2>&1) &&
      curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | sudo bash -s -- --repo rossmacarthur/sheldon --to /usr/local/bin
    ;;
  "Darwin" )
    (! type brew &>/dev/null 2>&1) &&
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    (! type sheldon &>/dev/null 2>&1) &&
      brew install sheldon

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
    ;;
  *) exit 1;;
esac

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
ln -snfv "$DOTFILES_DIR"/.gitconfig ~/.gitconfig
ln -snfv "$DOTFILES_DIR"/.gitignore_global ~/.gitignore_global
mkdir -p ~/.config/sheldon
ln -snfv "$DOTFILES_DIR"/plugins.toml ~/.config/sheldon/plugins.toml
ln -snfv "$DOTFILES_DIR"/.tmux.conf ~/.tmux.conf
mkdir -p ~/.config/mise
ln -snfv "$DOTFILES_DIR"/.mise.toml ~/.config/mise/config.toml
ln -snfv "$DOTFILES_DIR"/.vimrc ~/.vimrc
ln -snfv "$DOTFILES_DIR"/.zprofile ~/.zprofile
ln -snfv "$DOTFILES_DIR"/.zshrc ~/.zshrc
ln -snfv "$DOTFILES_DIR"/.zshrc_aliases_functions ~/.zshrc_aliases_functions
ln -snfv "$DOTFILES_DIR"/.npmrc ~/.npmrc
ln -snfv "$DOTFILES_DIR"/.bunfig.toml ~/.bunfig.toml
ln -snfv "$DOTFILES_DIR"/.default-npm-packages ~/.default-npm-packages
mkdir -p ~/.codex
ln -snfv "$DOTFILES_DIR"/.codex-config.toml ~/.codex/config.toml
mkdir -p ~/.claude
ln -snfv "$DOTFILES_DIR"/claude/CLAUDE.md ~/.claude/CLAUDE.md
mkdir -p ~/.config
ln -snfv "$DOTFILES_DIR"/aerospace ~/.config/aerospace

# Install Claude Code natively (auto-updates)
(! type claude &>/dev/null 2>&1) &&
  curl -fsSL https://claude.ai/install.sh | bash

if [ -z "${REMOTE_CONTAINERS:-}" ] && ! echo "$SHELL" | grep -q zsh; then
  chsh -s "$(which zsh)"
fi
