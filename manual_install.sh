# shellcheck disable=SC2148
# Terminal
open ~/dotfiles/MyProfile.terminal
defaults write com.apple.terminal "Default Window Settings" -string "MyProfile"
defaults write com.apple.Terminal "Startup Window Settings" -string "MyProfile"

# Homebrew bundle
brew bundle --global

# link to dropbox
ln -snfv ~/dropbox/settings/.zsh_history ~/.zsh_history
mkdir -p ~/.config
ln -snfv ~/dropbox/settings/karabiner ~/.config/karabiner

# Visual Studio Code Insiders
# https://code.visualstudio.com/insiders/
