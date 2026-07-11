#!/usr/bin/env bash

set -euo pipefail

case $(uname) in
  "Linux" )
    ! grep -qE '^ID=(debian|ubuntu)' /etc/os-release && exit 1

    sudo apt update && sudo apt -y install curl git less vim zsh
    (! type sheldon &>/dev/null 2>&1) &&
      curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | sudo bash -s -- --repo rossmacarthur/sheldon --to /usr/local/bin
    ;;
  "Darwin" )
    if ! type brew &>/dev/null 2>&1; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
      brew install sheldon mise fzf zoxide carapace
    fi
    ;;
  *) exit 1;;
esac

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
ln -snfv "$DOTFILES_DIR"/homebrew/.Brewfile ~/.Brewfile
ln -snfv "$DOTFILES_DIR"/git/.gitconfig ~/.gitconfig
ln -snfv "$DOTFILES_DIR"/git/.gitignore_global ~/.gitignore_global
mkdir -p ~/.config/sheldon
ln -snfv "$DOTFILES_DIR"/shell/plugins.toml ~/.config/sheldon/plugins.toml
ln -snfv "$DOTFILES_DIR"/tmux/.tmux.conf ~/.tmux.conf
mkdir -p ~/.config/mise
ln -snfv "$DOTFILES_DIR"/mise/.mise.toml ~/.config/mise/config.toml
ln -snfv "$DOTFILES_DIR"/vim/.vimrc ~/.vimrc
ln -snfv "$DOTFILES_DIR"/shell/.zprofile ~/.zprofile
ln -snfv "$DOTFILES_DIR"/shell/.zshrc ~/.zshrc
mkdir -p ~/.config/zsh
ln -snfv "$DOTFILES_DIR"/shell/completions ~/.config/zsh/completions
ln -snfv "$DOTFILES_DIR"/pkg/.npmrc ~/.npmrc
mkdir -p ~/.config/pnpm
ln -snfv "$DOTFILES_DIR"/pkg/pnpm-config.yaml ~/.config/pnpm/config.yaml
ln -snfv "$DOTFILES_DIR"/pkg/.bunfig.toml ~/.bunfig.toml
ln -snfv "$DOTFILES_DIR"/pkg/.gemrc ~/.gemrc
mkdir -p ~/.config/uv ~/.config/pip ~/.config/go ~/.cargo
ln -snfv "$DOTFILES_DIR"/pkg/uv.toml ~/.config/uv/uv.toml
ln -snfv "$DOTFILES_DIR"/pkg/pip.conf ~/.config/pip/pip.conf
ln -snfv "$DOTFILES_DIR"/pkg/cargo-config.toml ~/.cargo/config.toml
ln -snfv "$DOTFILES_DIR"/pkg/go-env ~/.config/go/env
mkdir -p ~/.codex/rules
ln -snfv "$DOTFILES_DIR"/codex/AGENTS.md ~/.codex/AGENTS.md
ln -snfv "$DOTFILES_DIR"/codex/rules/default.rules ~/.codex/rules/default.rules
mkdir -p ~/.claude/skills
ln -snfv "$DOTFILES_DIR"/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -snfv "$DOTFILES_DIR"/claude/settings.json ~/.claude/settings.json
ln -snfv "$DOTFILES_DIR"/claude/statusline.sh ~/.claude/statusline.sh
ln -snfv "$DOTFILES_DIR"/claude/skills/pr ~/.claude/skills/pr
mkdir -p ~/.config/ghostty
ln -snfv "$DOTFILES_DIR"/ghostty/config.ghostty ~/.config/ghostty/config.ghostty
mkdir -p ~/.config/cmux
ln -snfv "$DOTFILES_DIR"/cmux/cmux.json ~/.config/cmux/cmux.json
mkdir -p ~/.config/herdr
ln -snfv "$DOTFILES_DIR"/herdr/config.toml ~/.config/herdr/config.toml

# Local / private overrides (optional)
DOTFILES_LOCAL_DIR="${DOTFILES_LOCAL_DIR:-$HOME/ghq/github.com/ywada526/dotfiles.local}"
if [ -x "$DOTFILES_LOCAL_DIR/install.sh" ]; then
  "$DOTFILES_LOCAL_DIR/install.sh"
fi

if [ -z "${REMOTE_CONTAINERS:-}" ] && ! echo "${SHELL:-}" | grep -q zsh; then
  chsh -s "$(which zsh)"
fi
