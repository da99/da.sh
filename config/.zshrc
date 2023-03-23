
TRAPUSR1() { rehash }

export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export TZ=:/etc/localtime
export TERM='xterm-256color'


fpath=(/apps/da.sh/zsh-functions $fpath)
autoload -Uz /apps/da.sh/zsh-functions/*
bindkey -v
export KEYTIMEOUT=1
cursor_mode

# =================================================================
# History
HISTFILE=~/.zsh.histfile
HISTSIZE=500
SAVEHIST=500
setopt appendhistory
# =================================================================
HISTORY_SUBSTRING_SEARCH_FUZZY="true"
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE="true"
 bindkey '^[[A' history-substring-search-up
 bindkey '^[[B' history-substring-search-down
# bindkey '^[[1;5A' history-substring-search-up
# bindkey '^[[1;5B' history-substring-search-down
# bindkey "$terminfo[kcuu1]" history-substring-search-up
# bindkey "$terminfo[kcud1]" history-substring-search-down
# =================================================================


setopt CORRECT # suggest correct commands
setopt PROMPT_SUBST

autoload -U add-zsh-hook
add-zsh-hook precmd precmd_git_prompt
precmd_git_prompt() {
  git_prompt="$(da.sh zsh git prompt)"
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
source /progs/fzf-tab/fzf-tab.plugin.zsh
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
alias grep="grep --color=always"
# =================================================================


# =================================================================
# Highlighting: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
# NOTE: zsh-syntax-highlighting must be the last plugin sourced.
source /progs/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# NOTE: zsh-history-substring-search must be sourced after syntax highlighting.
source /progs/zsh-history-substring-search/zsh-history-substring-search.zsh
# =================================================================
autoload -U colors && colors
PROMPT='%{$fg[green]%}%n%{$reset_color%}@%{$fg[green]%}%m%{$reset_color%} %{$fg[yellow]%}%~%{$reset_color%} ${git_prompt}%(?.. %S%F{9}$?%f%s )%#%{$reset_color%} '
# =================================================================
