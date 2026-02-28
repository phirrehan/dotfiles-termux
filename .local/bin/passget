#!/bin/sh

# If password name is provided in argument
[ -n "$1" ] && arg1="$(basename $1)" &&
  arg1_without_ext=${arg1%.*}
[ -f "$PASSWORD_STORE_DIR/$1.gpg" ] && pass -c "$1" && exit 0

# Otherwise get password name using fzf
password_name=$(ls $PASSWORD_STORE_DIR | sed 's/\.gpg$//' | fuzzel --dmenu)

# Exit if no password is selected
[ -z "$password_name" ] && exit 1

# Copy password
pass -c "$password_name"
