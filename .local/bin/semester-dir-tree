#!/bin/bash

UNINAME="comsats"

# Functions
makeTree() {
  mkdir $semDir/"Semester $semNum"
  for i in $(seq 1 $subjectsNum); do
    mkdir $semDir/"Semester $semNum"/"Subject $i"
    for j in $(seq 1 16); do
      mkdir $semDir/"Semester $semNum"/"Subject $i"/"Week $j"
    done
    mkdir $semDir/"Semester $semNum"/"Subject $i"/"Books"
  done
}
deleteTree() {
  rm -rf $semDir/"Semester $semNum"
}

# Get Input 
read -p "Enter directory where semester files should be stored: " semDir
## Replace ~ with $HOME if present in semDir
[ "$(echo $semDir | cut -c 1)" = "~" ] &&
  semDir=$(echo $semDir | sed "s|~|$HOME|")
## If no directory was provided, find a university directory
[ -z "$semDir" ] && [ -d "$HOME/files" ] &&
  semDir=$(find "$HOME/files" -type d -iname "$UNINAME")
## Check if directory exists
[ ! -d "$semDir" ] &&
  echo "Error: Directory not found" && exit 1

read -p "Enter semester number: " semNum
[[ ! "$semNum" =~ ^[0-9]$ ]] && # Check if Semester number is valid
  echo "Error: Invalid Number" && exit 2

read -p "Enter number of subjects: " subjectsNum
[[ ! "$subjectsNum" =~ ^[0-9]+$ ]] && # Check if Subjects number is valid
  echo "Error: Invalid Number" && exit 3

# Make Semester Tree
makeTree || {
  echo "Unknown Error Occurred"
  deleteTree
}

