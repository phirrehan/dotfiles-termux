#!/bin/bash

PDFVIEWER="zathura"

# Functions
manual() {
  echo "This script runs a program without leaving any residue file in system. It can run C, C++, python, and LaTeX codes. It can run multiple files."
  echo "Dependencies:"
  echo "For C/C++: clang"
  echo "For Python: python"
  echo "For LaTeX: texlive\n"
  echo "Usage: $0 /path/to/file1 /path/to/file2 ..."
  # echo "The --arg option is used to pass arguments to the program's binary." echo "Use --help or -h options to print this manual." }
}

PY() {
  python $file_path
}

C() {
  clang "$file_path" -o "$file_dir/$file_without_ext" &&
    "$file_dir/$file_without_ext"
  rm "$file_dir/$file_without_ext" >/dev/null
}

CPP() {
  if ls "$file_dir" | grep -q "Makefile"; then
    make -C "$file_dir" clean >/dev/null
    make -C "$file_dir" >/dev/null && "$file_dir/$file_without_ext"
  else
    rm "$file_dir/$file_without_ext" 2>/dev/null
    g++ "$file_path" -o "$file_dir/$file_without_ext" &&
      "$file_dir/$file_without_ext"
  fi
}

JAVA() {
  package=$(grep -oP "package \K[^;]+" "$file_path")
  if [ -n "$package" ]; then
    javac -d tmp "src/$package/$file_name" &&
      java -cp 'tmp:assets' "$package.$file_without_ext"
    rm -rf tmp
  else
    javac "$file_name" &&
      java "$file_without_ext" &&
      rm "$file_dir/"*".class"
  fi
}

TEX() {
  pdflatex -no-shell-escape -halt-on-error -interaction=nonstopmode "$file_path" >/dev/null && {
    $PDFVIEWER "$file_dir/$file_without_ext.pdf"
    rm "$file_dir/$file_without_ext.pdf"
    rm "$file_dir/$file_without_ext.aux"
    rm "$file_dir/$file_without_ext.log"
  }
}
# Errors
for arg in $@; do
  [ "$arg" = "--help" -o "$arg" = "-h" ] && manual && exit 0
  [ -f $arg ] || {
    echo -e "\e[0;31mError: file not found. \e[0m" &&
      exit 1
  }
done

for arg in $@; do
  file_path="$arg"
  file_dir="$(dirname $file_path)"
  file_name="$(basename $file_path)"
  file_without_ext="${file_name%.*}"
  file_ext="${file_name##*.}"

  case $file_ext in
  'c') C ;;
  'cpp') CPP ;;
  'py') PY ;;
  'tex') TEX ;;
  'java') JAVA ;;
  *) echo -e "\e[0;31mInvalid file format. Exiting...\e[0m" && exit 2 ;;
  esac
done
