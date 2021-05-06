# Control Options
setopt no_flow_control
setopt no_beep
setopt ignore_eof

# History Options
HISTSIZE=1000000 SAVEHIST=1000000
setopt extended_history
setopt hist_reduce_blanks
setopt share_history

# Word Characters
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " !\"#$%&'()*+,-./:;<=>?@[\]^_\`{|}~"
zstyle ':zle:*' word-style unspecified

# Binding Keys
bindkey -e

# Aliases and Functions
alias ks='kubectl'
alias dk='docker'
alias dc='docker-compose'

alias ls='ls -GF'
alias la='ls -la'

alias glg='git log --graph --oneline'

alias tree='tree -I "node_modules" -Ca'
alias gibo='docker run --rm simonwhitaker/gibo'

gho() {
  hub browse -- pull/$(git symbolic-ref --short HEAD)
}

ghoi() {
  branches=$(git branch -r | egrep -v '\*|develop|master' | sed -e 's/origin\///g' -e 's/^[ \t]*//')
  if [ -z $branches ]; then
    echo 'There are no remote branches'
    return 1
  fi
  branch=$(echo -n $branches | fzf)
  if [ -z $branch ]; then
    return 1
  fi
  hub browse -- pull/$branch
}

delete-all-branch() {
  git branch --merged | egrep -v '\*|develop|master' | xargs git branch -d
}

# Completions
zstyle ':completion:*:default' menu true select
zstyle ':completion:*' format '%F{blue}%BCompleting %d%b%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# Packages
source ~/.zinit/bin/zinit.zsh

zinit ice wait lucid atinit'zicompinit; zicdreplay'
zinit light zdharma/fast-syntax-highlighting

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

zinit ice wait lucid pick'init.sh'
zinit light b4b4r07/enhancd
ENHANCD_FILTER=fzf

zinit ice lucid
zinit light dracula/zsh
setopt prompt_subst
ZSH_THEME_GIT_PROMPT_PREFIX="%F{default}("
PROMPT='%(1V:%F{yellow}:%(?:%F{green}:%F{red}))%B%# '
PROMPT+='%F{default}$(dracula_context)'
PROMPT+='%c '
PROMPT+='$DRACULA_GIT_STATUS'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(anyenv init -)"
