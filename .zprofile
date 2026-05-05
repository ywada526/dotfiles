[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Pin pnpm (and other XDG-aware tools) to ~/.config instead of macOS-native
# ~/Library/Preferences. Most other tools (mise, gh, git) already write here.
export XDG_CONFIG_HOME="$HOME/.config"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/mise/shims:$PATH"
# Stubs for npm/npx/corepack — must come AFTER mise shims so they win.
# Force pnpm by erroring out on any npm/npx/corepack invocation.
export PATH="$HOME/dotfiles/pnpm/bin:$PATH"
