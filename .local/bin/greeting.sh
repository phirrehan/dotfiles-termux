#!/bin/sh

# variables
file="$HOME/.local/bin/.greeting.txt"
greeting="Welcome"
if [ -s "$file" ]; then 
  total_lines=$(awk 'END { print NR }' "$file")
  greeting=$(awk -v n=$((RANDOM % total_lines + 1)) 'NR == n {print; exit}' "$file") # stores text in $file at line $random_line
fi

# start
printf '\033[36m'  # Set colour to cyan
if command -v figlet &>/dev/null; then 
  figlet -tf small "$greeting" | sed 's/^/  /' 
else
  echo "Please install figlet for appropriate message."
fi
printf '\033[0m'
command -v fastfetch &> /dev/null && fastfetch --key-padding-left 5
