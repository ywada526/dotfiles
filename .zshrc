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
source <(COMPLETE=zsh jj)


. ~/.zshrc_aliases_functions
[ -f ~/.zshrc_private ] && . ~/.zshrc_private || true
