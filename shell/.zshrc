bindkey -e

setopt no_flow_control no_beep ignore_eof extended_glob

HISTSIZE=1000000 SAVEHIST=1000000
setopt extended_history hist_reduce_blanks share_history

autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " /:@+|-="
zstyle ':zle:*' word-style unspecified

zstyle ':completion:*:default' menu true select
zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' format '%F{blue}%BCompleting %d%b%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Custom completion functions live under shell/completions/ in this repo
# (symlinked into ~/.config/zsh/completions by install.sh). Must come
# before compinit so new functions are picked up.
fpath=(~/.config/zsh/completions $fpath)

# Run full compinit (with $fpath security audit) at most once a day;
# otherwise reuse the cached dump. The audit costs ~200ms; -C skips it.
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh-24) ]]; then
  compinit -C
else
  compinit
fi

(( $+commands[sheldon] )) && eval "$(sheldon source)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# zsh-defer is provided by sheldon; defer non-prompt-critical inits so the
# first prompt appears immediately and these load shortly after.
if (( $+functions[zsh-defer] )); then
  (( $+commands[fzf] ))      && zsh-defer eval 'source <(fzf --zsh)'
  (( $+commands[carapace] )) && zsh-defer eval 'source <(carapace _carapace zsh)'
  (( $+commands[mise] ))     && zsh-defer eval '$(mise activate zsh)'
fi

. ~/dotfiles/shell/aliases.zsh
. ~/dotfiles/shell/functions.zsh

[ -f ~/.zshrc.local ] && . ~/.zshrc.local || true
