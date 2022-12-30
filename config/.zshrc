

export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export TZ=:/etc/localtime
export TERM='xterm-256color'

fpath=(/apps/da.sh/zsh-functions $fpath)
autoload -Uz /apps/da.sh/zsh-functions/*


# =================================================================
# Auto-completion
# =================================================================
# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate
zstyle :compinstall filename '/home/da/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# =================================================================


# =================================================================
# History
HISTFILE=~/.zsh.histfile
HISTSIZE=500
SAVEHIST=500
setopt appendhistory
# =================================================================
source /progs/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[1;5A' history-substring-search-up
bindkey '^[[1;5B' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
# =================================================================


setopt CORRECT # suggest correct commands
setopt PROMPT_SUBST

autoload -U add-zsh-hook
add-zsh-hook precmd precmd_git_prompt
precmd_git_prompt() {
  git_prompt="$(da.sh zsh git prompt)"
}

source /progs/zsh-autosuggestions/zsh-autosuggestions.zsh

# =================================================================
# Highlighting: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
# NOTE: zsh-syntax-highlighting must be the last plugin sourced.
source /progs/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# =================================================================

# =================================================================
# Aliases:
# From: https://superuser.com/questions/1514569/how-to-expand-aliases-inline-in-zsh
zstyle ':completion:*' completer _expand_alias _complete _ignored
# =================================================================
alias .="git status"
alias devcheck="git commit -m 'Development checkpoint.'"
alias gc="git clone --depth 1"
# =================================================================

PROMPT='%F{108}%n%F{240}@%F{108}%m%f %F{222}%~%f ${git_prompt}%(?.. %S%F{9}$?%f%s )%F{8}%#$f '

