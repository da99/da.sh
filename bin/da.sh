#!/usr/bin/env zsh
#
#
set -u -e -o pipefail


case "$(echo "$@" | xargs)" in
  "update .ssh")
    if test -d ~/.ssh ; then
      echo "=== chmod .ssh"
      chmod 700 $HOME/.ssh
      # chmod 700 $HOME/.ssh/config
      chmod 600 $HOME/.ssh/*
      chmod 644 $HOME/.ssh/*.pub
    fi
    ;;

  "update")
    "$0" check dirs
    "$0" update progs
    "$0" install dev packages
    "$0" update .ssh

    if which apt >/dev/null ; then
      echo "=== APT ===" >&2
      sudo apt update
      sudo apt upgrade
    fi
    ;;

  "git pull progs")
    cd /progs
    for repo in zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search ; do
      if ! test -d "/progs/$repo"; then
        cd /progs
        echo "=== Cloning: $repo ===" >&2
        git clone --depth 1 "https://github.com/zsh-users/$repo"
      fi
    done

    while read -r git_dir; do
      cd "$git_dir"/..
      echo
      echo "=== git pull in $PWD"
      git pull || read -s -k '?Press any key to continue.'
    done < <(find /progs/ -mindepth 2 -maxdepth 2 -type d -name .git)
    ;;

  "check dirs")
    for dir in progs apps ; do
      if ! test -e "/$dir"; then
        echo "!!! Does not exist: $dir" >&2
        exit 1
      fi
    done
    ;;

  "install dev packages")
    if which apt >/dev/null; then
      echo "=== Installing packages... ==="
      sudo apt install fish neovim \
        wget \
        tree git-all curl smplayer ripgrep tree zsh htop \
        make gcc bat

      if ! which bat >/dev/null ; then
        mkdir -p $HOME/bin
        ln -s "$(which batcat)" $HOME/bin/bat
      fi
    fi # which apt
    ;;

  "new zsh "*)
    this_bin="${0:a:h}/.."
    da_bin="${this_bin}/.."
    new_file="$3"

    if test -e "$new_file" ; then
      echo "=== Already exists: $new_file" >&2
      exit 0
    fi

    cp -i "${this_bin}/templates/script.zsh" "$new_file"
    chmod +x "$new_file"
    echo "=== Created: $new_file" >&2
    ;;

  "zsh git prompt")
    if ! git -C $PWD rev-parse 2> /dev/null; then
      echo ''
      exit 0
    fi

    git_prompt=''
    current_branch="$(git branch --show)"
    if $0 repo is clean; then
      case "$current_branch" in
        main|master)
          git_prompt='[%F{71}'${current_branch}'%f]'
          ;;
        *)
          git_prompt='[%S%F{214}'${current_branch}'%f%s]'
          ;;
      esac
    else
      git_prompt='[%S%F{9}'${current_branch}'%f%s]'
    fi
    if test -n "$git_prompt"; then
      echo "${git_prompt} "
    fi
    ;;

  # =========================================================================
  # GIT
  # =========================================================================

  "repo pull all")
    "$0" git pull progs
    cd /apps/da.sh
    echo "=== git pull in $PWD ===" >&2
    git pull

    ;;

  "repo is clean")
    if ! test -d .git ; then
      exit 1
    fi
    test -z "$(git status --porcelain --ignore-submodules)" && [[ "$(git status)" = *"Your branch is up to date with 'origin/"* ]]
    ;;

  "repo list")
    echo "$HOME"
    find /apps/ -mindepth 1 -maxdepth 1 -type d
    ;;

  "repo list dirty")
    for x in $($0 repo list); do
      cd "$x"
      if ! "$0" repo is clean; then
        echo "$x"
      fi
    done
    ;;

  *)
    # === It's an error:
    echo "!!! Unknown action for $0: $@" 1>&2
    exit 1
    ;;
esac
