#!/bin/bash

[ -z "$MILK_LIST_DIR" ] && MILK_LIST_DIR="$HOME/files/milkList"

# Functions
manual() {
  echo "This script writes the date(of Nagha or Double Milk) in format YYYY-MM-DD in a file in $MILK_LIST_DIR/<recordHolder>/<month>. The month is written in format MM-YYYY and it is automatically generated if its not created."
  echo ""
  echo "Usage: $0 <mode> <recordHolder> <days>"
  echo "Example: $0 nagha Jeremy 0"
  echo ""
  echo "Arguments"
  echo "mode may be 'nagha' or 'double'. Note that --help or -h may be used as the first argument to display this manual."
  echo "recordHolder is the name of the person whose record is kept. It is stored in $MILK_LIST_DIR."
  echo "days must be an integer. 0 means today. Negative number means day in past. Positive number means day in future."
}

writeNagha() {
  # writeNagha() expects 1 argument for name of person.

  file="$MILK_LIST_DIR/$1/$recordName"
  [ ! -f "$file" ] && touch $file
  grep -qi "$Date" "$file" ||
    echo "Nagha on $Date" >>"$file"
}
writeDouble() {
  # writeDouble() expects 1 argument for name of person.

  file="$MILK_LIST_DIR/$1/$recordName"
  [ ! -f "$file" ] && touch $file
  grep -qi "$Date" "$file" ||
    echo "Double Milk on $Date" >>"$file"
}
displayRecord() {
  # displayRecrod() expects 1 argument for name of person.
  echo -e "$1's Record\n" &&
    cat $MILK_LIST_DIR/$1/$recordName && echo ""
}

# Argument handeling
if [ "$1" = "nagha" ]; then
  naghaFlag=true
elif [ "$1" = "double" ]; then
  doubleFlag=true
elif [ "$1" = "--help" -o "$1" = "-h" ]; then
  manual
else
  echo "error: invalid or no argument provided"
  exit 1
fi

recordHolder="$2"
days="$3"

# Check for errors
[ ! -d $MILK_LIST_DIR/taiAmmi ] &&
  echo "Error: directory $MILK_LIST_DIR/taiAmmi does not exist." && exit 2
[ ! -d $MILK_LIST_DIR/abji ] &&
  echo "Error: directory $MILK_LIST_DIR/abji does not exist." && exit 3
[ -z $recordHolder ] &&
  echo "Error: second argument not provided" && manual && exit 4
[ -z $days ] &&
  echo "Error: third argument not provided" && manual && exit 5

# Date format: MM-YYYY and YYYY-MM-DD respectively
recordName=$(date -d "$days days" +%m-%Y)
Date=$(date -d "$days days" +%Y-%m-%d)

# Write Naghas or Double Milk
if [ "$recordHolder" = "all" ]; then
  for name in $(ls $MILK_LIST_DIR); do
    [ "$naghaFlag" = "true" ] && writeNagha $name
    [ "$doubleFlag" = "true" ] && writeDouble $name
    displayRecord $name
    echo ""
  done
else
  [ "$naghaFlag" = "true" ] && writeNagha $recordHolder
  [ "$doubleFlag" = "true" ] && writeDouble $recordHolder
  displayRecord $recordHolder
  echo ""
fi
