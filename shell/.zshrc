bindkey -e

setopt no_flow_control no_beep ignore_eof extended_glob

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

# Run full compinit (with $fpath security audit) at most once a day;
# otherwise reuse the cached dump. The audit costs ~200ms; -C skips it.
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh-24) ]]; then
  compinit -C
else
  compinit
fi

(type sheldon &>/dev/null 2>&1) && eval "$(sheldon source)"

zstyle ':completion:*' completer _expand _complete _approximate
source <(carapace _carapace)

(type mise &>/dev/null 2>&1) && zsh-defer eval '$(mise activate zsh)'

[ -f ~/.zshrc.local ] && . ~/.zshrc.local || true
