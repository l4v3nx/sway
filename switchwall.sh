#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/ags"

switch() {
  imgpath=$1

  if [ "$imgpath" == '' ]; then
    echo 'Aborted'
    exit 0
  fi

  swww img "$imgpath" --transition-step 100 --transition-fps 60 \
    --transition-type grow --transition-angle 30 --transition-duration 1
}

if [ "$1" == "--noswitch" ]; then
  imgpath=$(swww query | awk -F 'image: ' '{print $2}')
elif [[ "$1" ]]; then
  switch "$1"
else
  # Select and set image

  cd "$(xdg-user-dir PICTURES)/wallpapers" || return 1
  switch "$(yad --file --add-preview --large-preview --title='Choose wallpaper')"
fi

# Generate colors for ags n stuff
"$CONFIG_DIR"/scripts/color_generation/colorgen.sh "${imgpath}" --apply --smart

sleep 1 && swaymsg reload
pkill mako && nautilus -q
mako
