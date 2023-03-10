#!/usr/bin/env zsh
#
#
set -u -e -o pipefail

THIS_DIR="${0:a:h}/.."
THIS_NODE_RB="$THIS_DIR/src/node.rb"
THIS_SRC="$THIS_DIR/src"

case "$(echo "$@" | xargs)" in
  help)
    cmd="da.sh"
    echo "$cmd list select"
    echo "       fzf with customized options."
    echo "$cmd hud my cmd with args"
    echo "       Takes output and replace newlines with '|'"
    echo "$cmd screen sleep"
    echo "       Waits 2 seconds and shuts off monitor."
    echo "$cmd all screens tear free"
    echo "       Waits 2 seconds and shuts off monitor."
    echo "$cmd new zsh [new/file]"
    echo "$cmd bspwm config"
    echo "       Runs command BSPwm config optiosn via bspc."
    echo
    echo "$cmd edit packages"
    echo "$cmd list packages"
    echo "$cmd install packages"
    echo "       packages for software development."
    echo
    echo "$cmd progs list"
    echo "$cmd progs pull all"
    echo
    echo "$cmd node latest"
    echo "$cmd node latest install"
    echo "$cmd node latest remote file"
    echo "$cmd node is latest"
    echo
    echo "$cmd nvim is latest"
    echo
    echo "$cmd repo pull all"
    echo "$cmd repo is clean"
    echo "$cmd repo list dirty"
    echo "$cmd repo list"
    echo
    echo "$cmd wallpaper loop (cmd)"
    echo
    echo "$cmd music follow [cmd with args]"
    echo "$cmd music playing titles"
    echo "$cmd hud music playing titles"
    echo
    echo "$cmd pipewire install"
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
    sleep 5s && xset dpms force off;
    ;;

  "all screens tear free")
    # from: https://linuxreviews.org/HOWTO_fix_screen_tearing
    xrandr | grep ' connected' | cut -f 1 -d ' ' | while read display; do
      echo "xrandr --output $display --set TearFree on"
      xrandr --output $display --set TearFree on
    done
    ;;

  "hud music playing titles")
    output="$($0 music playing titles)"
    echo "${output//$'\n'/"   |   "}"
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

  "list select")
    exec fzf --preview="tree -L 2 -a {}" --tabstop=2 -i
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
    "$0" progs pull all
    "$0" install packages
    "$0" update .ssh
    "$0" update sshd

    if which apt >/dev/null ; then
      echo "=== APT ===" >&2
      sudo apt update
      sudo apt upgrade
    fi
    ;;

  "progs pull all") # git pull progs
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


  "install themes")
    mkdir -p $HOME/.local/share/konsole/
    cd $HOME/.local/share/konsole/
    if ! test -e Chester.colorscheme ; then
      wget "https://github.com/mbadolato/iTerm2-Color-Schemes/raw/master/konsole/Chester.colorscheme"
    fi
    ;;

  "install packages"|"install dev packages")
    if command -v xbps-install >/dev/null; then
      cd "$(dirname "$0")"/..
      set -x
      sudo xbps-install -S $("$0" list packages | tr '\n' ' ')
    else
      lsb_release -a
      exit 1
    fi
    ;;

  "edit packages")
    if which xbps-install ; then
      cd "$(dirname "$0")"/..
      lvim config/void.packages.txt || nvim config/void.packages.txt
    fi
    ;;

  "list packages")
    if command -v xbps-install >/dev/null; then
      cd "$(dirname "$0")"/..
      cat config/void.packages.txt | tr '\n' ' '
    else
      lsb_release -a
      exit 1
    fi
    ;;

  # ----------------------------------------------------------------


  # ----------------------------------------------------------------
  "node install latest")
  if $0 node is latest ; then
    exit 0
  fi
  cd "$HOME"
  mkdir -p bin
  cd bin
  latest="$("$THIS_NODE_RB" node latest)"
  remote_file="$("$THIS_NODE_RB" node latest remote file)"
  set -x
  rm -f "$remote_file"
  wget "$remote_file"
  tar -xf "$(basename "$remote_file")"
  rm -f node
  ln -s "$(basename "$remote_file" .tar.xz)" node
  node/bin/npm upgrade -g
  set +x
  echo
  echo "--- Installed: $PWD"
  node/bin/node --version
  ls node/bin
  ;;
  # ----------------------------------------------------------------

  # ----------------------------------------------------------------
  "progs list")
    find -L /progs -mindepth 1 -maxdepth 1 -type d -not -path '*/.*' 2>/dev/null
  ;;
  # ----------------------------------------------------------------

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
  # DENO
  # =========================================================================
  "deno install latest")
  cd "$HOME/bin"
  if test -e deno ; then
    deno upgrade
    exit 0
  fi
  remote_file="https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip"
  wget "$remote_file"
  unzip "$(basename "$remote_file")"
  echo
  echo "--- Installed:"
  ./deno --version
  ;;

  # =========================================================================
  # NVIM
  # =========================================================================
  "nvim "*)
    "$THIS_SRC"/nvim.rb $@
  ;;

  # =========================================================================
  # Common commands:
  # =========================================================================

  "edit lvim config")
    set -x
    exec lvim "$HOME"/.config/lvim/config.lua
  ;;

  # =========================================================================
  # GIT
  # =========================================================================

  "repo pull all") # repo pull all
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

  "wallpaper loop "*)
    shift
    shift
    while read -r line ; do
      echo "Current: $line"
      feh --no-fehbg --bg-fill "$line"
      sleep 2
    done < <($@)
    ;;

  "music follow "*)
    shift
    shift
    while read -r line ; do
      echo "$line"
      $@
    done < <( playerctl --follow --all-players status )
    ;;

  "music playing titles")
    playerctl -a metadata title
    ;;

  "pipewire install")
    set -x
    sudo xbps-install -S pipewire wireplumber libspa-bluetooth
    : "${XDG_CONFIG_HOME:=${HOME}/.config}"
    mkdir -p "${XDG_CONFIG_HOME}/pipewire"
    sed '/path.*=.*pipewire-media-session/s/{/#{/' /usr/share/pipewire/pipewire.conf > "${XDG_CONFIG_HOME}/pipewire/pipewire.conf"
    mkdir -p "${XDG_CONFIG_HOME}/pipewire/pipewire.conf.d"
    echo 'context.exec = [ { path = "/usr/bin/wireplumber" args = "" } ]' > "${XDG_CONFIG_HOME}/pipewire/pipewire.conf.d/10-wireplumber.conf"
    ;;

  *)
    "$THIS_NODE_RB" $@
    ;;
esac
