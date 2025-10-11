bindkey -e

setopt no_flow_control no_beep ignore_eof

HISTSIZE=1000000 SAVEHIST=1000000
setopt extended_history hist_reduce_blanks share_history

autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " /:@+|-="
zstyle ':zle:*' word-style unspecified

zstyle ':completion:*:default' menu true select
zstyle ':completion:*' format '%F{blue}%BCompleting %d%b%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
(type brew &>/dev/null 2>&1) && FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
autoload -Uz compinit && compinit

(type mise &>/dev/null 2>&1) && eval "$(mise activate zsh)"
(type sheldon &>/dev/null 2>&1) && eval "$(sheldon source)"
(type direnv &>/dev/null 2>&1) && eval "$(direnv hook zsh)"
# fzf integration - using safer method
if type fzf &>/dev/null 2>&1; then
  # Set up fzf key bindings and fuzzy completion
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  
  # Key bindings
  if [[ -f ~/.local/share/sheldon/repos/github.com/junegunn/fzf/shell/key-bindings.zsh ]]; then
    source ~/.local/share/sheldon/repos/github.com/junegunn/fzf/shell/key-bindings.zsh
  fi
  
  # Fuzzy completion
  if [[ -f ~/.local/share/sheldon/repos/github.com/junegunn/fzf/shell/completion.zsh ]]; then
    source ~/.local/share/sheldon/repos/github.com/junegunn/fzf/shell/completion.zsh
  fi
fi

. ~/.zshrc_aliases_functions
[ -f ~/.zshrc_private ] && . ~/.zshrc_private || true
