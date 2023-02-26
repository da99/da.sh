#!/usr/bin/env zsh
#
#
set -u -e -o pipefail


case "$(echo "$@" | xargs)" in
  help)
    cmd="da.sh"
    echo "$cmd hud my cmd with args"
    echo "       Takes output and replace newlines with '|'"
    echo "$cmd screen sleep"
    echo "       Waits 2 seconds and shuts off monitor."
    echo "$cmd new zsh [new/file]"
    echo "$cmd bspwm config"
    echo "       Runs command BSPwm config optiosn via bspc."
    echo "$cmd install packages"
    echo "       packages for software development."
    echo "$cmd edit packages"
    ;;

  "bspwm config")
    # ---------------------------------------------------------
    set -x
    bspc config border_width 2
    bspc config window_gap  4
    bspc config focused_border_color '#f46200'
    bspc config click_to_focus button1

    bspc config pointer_modifier mod4
    bspc config pointer_action1 move
    bspc config pointer_action2 none
    bspc config pointer_action3 resize_corner
    bspc config focus_follows_pointer false || echo "error: $?"
    set +x
    # ---------------------------------------------------------
    bspc rule -a '*' state=floating
    bspc rule -a Gnome-calculator state=floating
    bspc rule -a Galculator state=floating
    bspc rule -a Gpick state=floating
    bspc rule -a GParted state=floating center=true
    bspc rule -a File-roller state=floating
    bspc rule -a Nitrogen state=floating
    bspc rule -a Lxappearance state=floating center=true
    bspc rule -a Lxrandr state=floating
    bspc rule -a Pavucontrol state=floating center=true
    bspc rule -a Timeshift-gtk state=floating
    bspc rule -a qt5ct state=floating rectangle=700x470+0+0 center=on
    bspc rule -a SimpleScreenRecorder state=floating
    bspc rule -a Sxiv state=floating
    bspc rule -a Viewnior state=floating
    bspc rule -a mpv state=floating

    bspc rule -a 'Onboard' border=off focus=off manage=off state=floating
    bspc rule -a 'Polybar' manage=off border=off
    bspc rule -a 'Plank' manage=off border=off focus=off state=floating
    bspc rule -a Tint2 border=off manage=off layer=above state=floating
    bspc rule -a '*:Kunst' sticky=on layer=below border=off focus=off

    bspc rule -a Docky layer=above manage=on border=off focus=off locked=on
    bspc rule -a xfce4-notes floating=on

    bspc rule -l
    ;;

  "screen sleep")
    sleep 2s && xset dpms force off;
    ;;

  "hud "*)
    shift
    counter=0
    for x in $("$@") ; do
      if [[ counter -lt 1 ]]; then
        echo -n "$x"
      else
        echo -n " | $x"
      fi
      counter="$((counter + 1))"
    done
    echo
    ;;

  "update .ssh") # update .ssh
    if test -d ~/.ssh ; then
      echo "=== chmod .ssh"
      chmod 700 $HOME/.ssh
      # chmod 700 $HOME/.ssh/config
      chmod 600 $HOME/.ssh/*
      chmod 644 $HOME/.ssh/*.pub
    fi

    ;;

  "update sshd") # update sshd
    # --- SSHD config check
    sshd_config="/etc/ssh/sshd_config"
    my_config="$HOME/config/sshd_config"
    if ! sudo sshd -t -f "$my_config" ; then
      exit 1
    fi
    if ! diff "$sshd_config" "$my_config"  ; then
      echo
      echo "!!! sudo cp -i $my_config $sshd_config"
      exit 1
    fi
    ;;

  "update") # update
    "$0" check dirs
    "$0" git pull progs
    "$0" install packages
    "$0" update .ssh
    "$0" update sshd

    if which apt >/dev/null ; then
      echo "=== APT ===" >&2
      sudo apt update
      sudo apt upgrade
    fi
    ;;

  "git pull progs") # git pull progs
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

  "check dirs") # check dirs
    for dir in progs apps ; do
      if ! test -e "/$dir"; then
        echo "!!! Does not exist: $dir" >&2
        exit 1
      fi
    done
    ;;

  "install packages"|"install dev packages")
    if which xbps-install ; then
      cd "$(dirname "$0")"/..
      set -x
      sudo xbps-install -S $(cat config/void.packages.txt | tr '\n' ' ')
    fi
    ;;

  "edit packages")
    if which xbps-install ; then
      cd "$(dirname "$0")"/..
      lvim config/void.packages.txt || nvim config/void.packages.txt
    fi
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
    autoload -U colors && colors
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
      git_prompt="[%{$fg[red]%}${current_branch}%{$reset_color%}]"
    fi
    if test -n "$git_prompt"; then
      echo "${git_prompt} "
    fi
    ;;

  # =========================================================================
  # GIT
  # =========================================================================

  "repo pull all") # repo pull all
    "$0" git pull progs
    for dir in $($0 repo list) ; do
      cd "$dir"
      echo "=== git pull in $PWD ===" >&2
      git pull
    done


    ;;

  "repo is clean")
    if ! test -d .git ; then
      exit 1
    fi
    test -z "$(git status --porcelain --ignore-submodules)" && [[ "$(git status)" = *"Your branch is up to date with 'origin/"* ]]
    ;;

  "repo list dirty")
    for x in $($0 repo list); do
      cd "$x"
      if ! "$0" repo is clean; then
        echo "$x"
      fi
    done
    ;;

  "repo list")
    if test -e "$HOME/.git" ; then
      echo "$HOME"
    fi
    find -L /apps /media-lib -mindepth 1 -maxdepth 1 -type d -not -path '*/.*' 2>/dev/null
    ;;

  *)
    # === It's an error:
    echo "!!! Unknown action for $0: $@" 1>&2
    exit 1
    ;;
esac
