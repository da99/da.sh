

fpath=(/progs/da.sh/zsh-functions $fpath)
autoload -Uz /progs/da.sh/zsh-functions/*
export KEYTIMEOUT=1
cursor_mode

if test -e "$HOME/config/zsh-functions" ; then
  fpath=($HOME/config/zsh-functions $fpath)
  autoload -Uz $HOME/config/zsh-functions/*
  export KEYTIMEOUT=1
  cursor_mode
fi

# =================================================================
# History
HISTFILE=~/.zsh.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt HIST_IGNORE_ALL_DUPS
setopt appendhistory
# =================================================================
HISTORY_SUBSTRING_SEARCH_FUZZY="true"
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE="true"

echo_git_prompt() {
  autoload -U colors && colors
  if ! git -C $PWD rev-parse 2> /dev/null; then
    echo ''
    return
  fi

  git_prompt=''
  current_branch="$(git branch --show)"
  if da.sh repo is clean; then
    case "$current_branch" in
      main|master)
        git_prompt='[%F{71}'${current_branch}'%f]'
        ;;
      *)
        git_prompt='[%S%F{214}'${current_branch}'%f%s]'
        ;;
    esac
  else
    git_prompt="[%{$fg[red]%}${current_branch}%{$reset_color%}]"
  fi
  if test -n "$git_prompt"; then
    echo "${git_prompt} "
  fi
}

setopt CORRECT # suggest correct commands
setopt PROMPT_SUBST

autoload -U add-zsh-hook
add-zsh-hook precmd precmd_git_prompt
precmd_git_prompt() {
  git_prompt="$(echo_git_prompt)"
}

# =================================================================
# Auto-completion
# =================================================================
autoload -Uz compinit && compinit
# zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate
# zstyle ':completion:*' completer _expand_alias _complete _ignored
zstyle ':completion:*' completer _expand_alias _complete _ignored _match _correct _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# zstyle ':completion:*' rehash true
zstyle :compinstall filename "/home/$USER/.zshrc"
# =================================================================

# =================================================================
# NOTE: fzf-tab needs to be loaded after compinit, but before plugins which will wrap widgets, such as zsh-autosuggestions or fast-syntax-highlighting!!
source /progs/fzf-tab/fzf-tab.zsh
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# =================================================================

# =================================================================
# Auto-suggestions
# =================================================================
source /progs/zsh-autosuggestions/zsh-autosuggestions.zsh
# =================================================================

# =================================================================
# Aliases:
# From: https://superuser.com/questions/1514569/how-to-expand-aliases-inline-in-zsh
# =================================================================
alias .="git status"
alias devcheck="git commit -m 'Development checkpoint.'"
alias gc="git clone --depth 1"
alias gtypo="git commit -am \"Typo.\""
alias grep="grep --color=always"
alias ls="exa -aF --icons --color=always --group-directories-first"
alias rgg="rg --no-ignore --smart-case"
alias "tree"="/usr/bin/tree -al"
# =================================================================


# =================================================================
# Highlighting: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
# NOTE: zsh-syntax-highlighting must be the last plugin sourced.
source /progs/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# NOTE: zsh-history-substring-search must be sourced after syntax highlighting.
source /progs/zsh-history-substring-search/zsh-history-substring-search.zsh
# =================================================================
autoload -U colors && colors
PROMPT=$'\n''%{$fg[green]%}%n%{$reset_color%}@%{$fg[green]%}%m%{$reset_color%} %{$fg[yellow]%}%~%{$reset_color%} ${git_prompt}%(?.. %S%F{9}$?%f%s )%{$reset_color%}'$'\n'' ↳ '
# =================================================================

# =================================================================
# When starting a new terminal, CD into the last known directory.
# =================================================================
# cd () {
#   builtin cd "$@"
#   echo $PWD > /tmp/last.cd
# }

# if test -f /tmp/last.cd ;
# then
#   local _last_cd="$(cat /tmp/last.cd)"
#   if test -e "$_last_cd" ; then
#     builtin cd "$_last_cd"
#   else
#     rm /tmp/last.cd
#   fi
# fi
# =================================================================

# Put bindings on last to prevent issues with Ubuntu:
# https://jdhao.github.io/2019/06/13/zsh_bind_keys/
# bindkey -v # turn on VI bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1;5C" forward-word
# bindkey '^[[1;5A' history-substring-search-up
# bindkey '^[[1;5B' history-substring-search-down
# bindkey "$terminfo[kcuu1]" history-substring-search-up
# bindkey "$terminfo[kcud1]" history-substring-search-down
# =================================================================

if type mise &>/dev/null ; then
  eval "$(mise activate zsh)"
fi

# =================================================================
# When starting a new terminal, CD into the last known directory.
# =================================================================
test -e "$HOME/tmp" || mkdir "$HOME/tmp"
cd () {
  builtin cd "$@"
  echo $PWD > "$HOME/tmp/last.cd"
}

if test -f "$HOME/tmp/last.cd" ;
then
  local _last_cd="$(cat "$HOME"/tmp/last.cd)"
  if test -e "$_last_cd" ; then
    builtin cd "$_last_cd"
  else
    rm "$HOME"/tmp/last.cd
  fi
fi
# =================================================================


