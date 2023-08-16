#!/usr/bin/env zsh
#
#
set -u -e -o pipefail

THIS_DIR="${0:a:h}/.."
THIS_NODE_RB="$THIS_DIR/src/node.rb"
THIS_SRC="$THIS_DIR/src"

case "$(echo "$@" | xargs)" in
  help|-h)
    cmd="da.sh"
    echo "$cmd check fs"
    echo "       Lists all things that need to be done."
    echo "$cmd check check fs"
    echo "       exits with either 0 or 1"
    echo
    echo "$cmd list select"
    echo "       fzf with customized options."
    echo "$cmd hud my cmd with args"
    echo "       Takes output and replace newlines with '|'"
    echo "$cmd screen sleep [5]"
    echo "       Waits 5 seconds and shuts off monitor."
    echo "$cmd all screens tear free"
    echo "       Waits 2 seconds and shuts off monitor."
    echo "$cmd new zsh|ruby|tmp/run [new/file/path.ext]"
    echo "$cmd bspwm config"
    echo "       Runs command BSPwm config optiosn via bspc."
    echo
    echo "$cmd edit packages"
    echo "$cmd list packages"
    echo "$cmd install packages"
    echo "       packages for software development."
    echo
    echo "$cmd install progs"
    echo "$cmd progs list"
    echo "$cmd upgrade progs"
    echo
    echo "$cmd node latest"
    echo "$cmd node latest install"
    echo "$cmd node latest remote file"
    echo "$cmd node is latest"
    echo
    echo "$cmd install openbox theme"
    echo
    echo "$cmd repo pull all"
    echo "$cmd repo is clean"
    echo "$cmd repo list dirty"
    echo "$cmd repo list"
    echo "$cmd repo cmd [my cmd with args]"
    echo
    echo "$cmd wallpaper loop (cmd)"
    echo
    echo "$cmd music snoop [cmd with args]"
    echo "$cmd music playing titles"
    echo "$cmd hud music playing titles"
    echo
    echo "$cmd pipewire install"
    echo
    echo "$cmd install obsidian theme"

    echo
    echo "$cmd mount sshfs [ssh:/point] [mount point]"
    echo "$cmd filename|run tmp/run 1|2|3"
    ;;

  "check fs")
    is_fine="yes"
    for dir in /apps /progs ; do
      if ! test -e "$dir" ; then
        echo "--- create $dir " >&2
        is_fine=""
      fi
    done
    for x in 5 6 ; do
      if test -e "/var/service/agetty-tty$x" ; then
        is_fine=""
        echo "--- sv down && rm /var/service/agetty-tty$x"
      fi
    done
    if test "$is_fine" = "yes" ; then
      echo "✔️ Everything setup."
    fi
    ;;

  "check check fs")
    errors="$("$0" check fs 2>&1 >/dev/null )"
    if test -z "$errors" ; then
      exit 0
    fi
    exit 1
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
    "$0" $@ 5
    ;;

  "screen sleep "*)
    shift;
    shift;
    sleep "$1"s && xset dpms force off;
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
    "$0" upgrade progs
    "$0" install packages
    "$0" update .ssh
    "$0" update sshd

    if which apt >/dev/null ; then
      echo "=== APT ===" >&2
      sudo apt update
      sudo apt upgrade
    fi
    ;;

  "install progs")
    "$0" check check fs || { "$0" check fs && exit 1 }
    for repo in "Aloxaf/fzf-tab" "zsh-users/zsh-syntax-highlighting" "zsh-users/zsh-autosuggestions" "zsh-users/zsh-history-substring-search" ; do
      dname="$(basename "$repo")"
      if test -d "/progs/$dname"; then
        echo "--- exists: /progs/$dname"
      else
        cd /progs
        echo "=== Cloning: $repo into $PWD/$dname ===" >&2
        echo git clone --depth 1 "https://github.com/$repo"
      fi
    done
    ;;

  "upgrade progs") # git pull progs
    cd /progs

    while read -r git_dir; do
      cd "$git_dir"/..
      dname="$(basename "$PWD")"
      case "$dname" in
        void-packages)
          echo "--- Skipping: $PWD" >&2
          continue
          ;;
        *)
          echo -n "=== git pull in $PWD: "
          git pull || read -s -k '?Press any key to continue.'
          ;;
      esac
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

  "run tmp/run "*)
    local filename="$("$0" filename tmp/run $3)"
    test -n "$filename"
    exec "$filename"
  ;;

  "filename tmp/run "*)
    local file_name="run.${3}.sh"
    local git_dir="$(git rev-parse --show-toplevel 2>/dev/null || : )"

    if test -z "$git_dir" ; then
      local tmp_dir="/tmp/tmp-run"
      file_name="${PWD//\//.}.${file_name}"
      mkdir -p "$tmp_dir"
      full_name="${tmp_dir}/${file_name}"
    else
      local tmp_dir="${git_dir}/tmp"
      mkdir -p "$tmp_dir"

      full_name="${tmp_dir}/${file_name}"
    fi

    da.sh new tmp/run "$full_name" 2>/dev/null
    echo  "$full_name"
  ;;

  "new zsh "*|"new ruby "*|"new tmp/run "*)
    this_bin="${0:a:h}/.."
    da_bin="${this_bin}/.."
    file_type="$2"
    new_file="$3"

    if test -e "$new_file" ; then
      echo "=== Already exists: $new_file" >&2
      exit 0
    fi

    case "$file_type" in
      zsh)
        cp -i "${this_bin}/templates/script.zsh" "$new_file"
        ;;
      "tmp/run")
        cp -i "${this_bin}/templates/tmp.run.zsh" "$new_file"
        ;;
      ruby)
        cp -i "${this_bin}/templates/script.rb" "$new_file"
        ;;
    esac
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
      echo -n "=== git pull in $PWD: " >&2
      git pull
    done


    ;;

  "repo is clean")
    test -z "$(git status --porcelain --ignore-submodules)" && [[ "$(git status)" = *"Your branch is up to date with 'origin/"* ]]
    ;;

  "repo list dirty")
    for x in $($0 repo list); do
      (
        cd "$x"
        if ! "$0" repo is clean; then
          echo "$x"
        fi
      ) &
    done
    wait
    ;;

  "repo list")
    {
      test -e "$HOME/.git" && echo "$HOME" || :
      dirs=( /apps )
      if test -e /media-lib ; then
        dirs+=(/media-lib)
      fi
      find -L ${dirs[@]} -mindepth 1 -maxdepth 1 -type d -not -path '*/.*' 2>/dev/null
    } | sort
    ;;

  "repo cmd "*)
    shift
    shift
    for x in $($0 repo list); do
      cd "$x"
      $@
    done
    ;;

  "wallpaper loop "*)
    shift
    shift
    while read -r line ; do
      echo "Current: $line"
      feh --no-fehbg --bg-fill "$line" || :
      sleep 5
    done < <($@)
    ;;

  "music snoop "*)
    shift
    shift
    while read -r line ; do
      echo "$line"
      $@ || notify-send "Error:" "music snoop command: $@"
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

  "install openbox theme")
    cd "$THIS_DIR"
    da_dir="$PWD"
    theme_name="plainborder"
    cd "$HOME"
    mkdir -p .themes
    cd .themes
    if test -e "$theme_name" ; then
      echo "!!! Already exists: $PWD/$theme_name"
      exit 1
    fi
    set -x
    ln -s "$da_dir"/config/plainborder $PWD/plainborder
    ;;

  "install obsidian theme")
    # from: https://www.2daygeek.com/obsidian-icons-theme-for-linux-desktop/
    mkdir -p "$HOME/.icons"
    cd /progs
    if ! test -e iconpack-obsidian ; then
      git clone --depth=1 https://github.com/madmaxms/iconpack-obsidian.git
    fi
    cd iconpack-obsidian
    while read -r raw ; do
      theme_name="$(basename "$raw")"
      if ! test -e "$HOME/.icons/$theme_name"; then
        echo "$PWD/$theme_name  --> $HOME/.icons/$theme_name" >&2
        ln -s "$PWD/$theme_name" "$HOME/.icons/$theme_name"
      fi
    done < <(find . -type d -maxdepth 1 -mindepth 1 -name "Obsidian*")
      # echo "!!! Already installed." >&2
    ;;

  "setup nvim")
    mkdir -p /progs/tmp/nvim

    if ! test -e $HOME/.config/nvim ; then
      ln -s /apps/da.sh/config/nvim $HOME/.config/
    fi
    echo "--- Installing OS packages:" >&2
    void_linux install packages devel
    echo "--- Installing nvim packages:" >&2
    nvim --headless -u NONE -c 'lua require("bootstrap").headless_paq()'
    echo ""
    echo "--- Done setting up nvim. ----" >&2
  ;;

"mount sshfs "*)
  local ssh_point="$3"
  local mpoint="$4"

  mkdir -p "$mpoint"

  cd "$mpoint"
  # -o Ciphers=arcfour \
  if mountpoint -q "$mpoint" ; then
    echo "--- Mounted: $mpoint" >&2
    notify-send "Already mounted:" "$mpoint"
    exit 0
  fi

  set -x
  sshfs \
    -o cache=yes \
    -o kernel_cache \
    -o reconnect \
    -o idmap=user \
    -o Ciphers=aes128-ctr \
    -o Compression=no     \
    -o ServerAliveCountMax=2 \
    -o ServerAliveInterval=15 \
    "$ssh_point" "$mpoint" &&
    notify-send "Mounted:" "$mpoint" || {
      notify-send "Error:" "Failed mounting $mpoint ($ssh_point)"
      exit 1
    }
  ;;

  *)
    "$THIS_NODE_RB" $@
    ;;
esac
