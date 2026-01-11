#!/bin/bash

export PASSWORD_STORE_DIR="$HOME/files/Passwords/store"
passName=$1   # First Argument is name of password
passLength=$2 # Second Argument is length of password
[ -z "$passLength" ] && passLength=20

# Check Errors
[[ ! "$passLength" =~ ^[0-9]+$ ]] &&
  echo "Error: invalid input. expected a number" &&
  read -p "Press enter to exit." && exit 1
[ $passLength -le 0 ] &&
  echo "Error: invalid input. expected a number greater than 0" &&
  read -p "Press enter to exit." && exit 2

# Generate password
pass generate -c "$passName" "$passLength"
