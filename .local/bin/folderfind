#!/bin/bash

# Run fzfmenu.sh to get the selected directory
selected_dir=$(fd --type directory --hidden . ~ | ~/.local/bin/fzfmenu "Select a directory")
echo "selected_dir: $selected_dir"
[ -z "$selected_dir" ] && exit 1

# Get the action to perform
index=$(
  printf "1 Terminal Tmux\n2 Dolphin\0icon\x1forg.kde.dolphin\n3 Yazi\0icon\x1fyazi\n4 Nvim\0icon\x1fnvim" |
    ~/.local/bin/fzfmenu "Select an application" |
    awk '{ print $1 }'
)
[ -z "$index" ] && exit 2

# Perform the action
case $index in
1) tmux -u new-session ;;
2) yazi ;;
3) nvim ;;
esac
