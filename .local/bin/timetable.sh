#!/bin/sh


### Variables ###
timetable_dir="$HOME/files/comsats/timetable"
old_pdf_name="$(ls $timetable_dir | grep -oP '.+-classes\.pdf')"
base_url="https://lahore.comsats.edu.pk"
search_url="$base_url/downloads.aspx"
download_url="$base_url/student" #incomplete as of yet

### Functions ###
help() {
  cat <<EOF
  Usage: $0 <args>
  Arguments        |        Function"
  -h or --help     | print this message"
  get_pdfname      | fetches the pdfname from timetable directory
  update           | update the timetable"
EOF
}
check_deps() {
  local missing=()
  local deps=(curl_chrome131_android grep pdfgrep pdftk)
  for cmd in "${deps[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done

  if ((${#missing[@]})); then
    echo "Missing required dependencies:" >&2
    for cmd in "${missing[@]}"; do
      echo "  - $cmd" >&2
    done
    exit 3
  fi
}
fetch_pdfname() {
  html=$(curl_chrome131_android -s "$search_url") &&
   printf $(echo $html | grep -oE '[^/]+-classes\.pdf') ||
    echo "pdfname fetch failed :(" && exit 5
}
download_pdf() {
  rm "$timetable_dir/full_timetable.pdf" 2>/dev/null
  curl_chrome131_android -o full_timetable.pdf "$download_url/$pdfname" || {
    echo ":( Download failed! Try again."
    exit 6
  }
}
extract_page() {
  local page="$(pdfgrep -n -i 'sp25-bse-a' "full_timetable.pdf" | cut -d: -f1 | sort -u)"
  pdftk "full_timetable.pdf" cat "$page" output "$pdfname"
  mv "$pdfname" full_timetable.pdf "$timetable_dir"
}
update_timetable() {
  # check internet access
  ping -c 1 google.com &>/dev/null || {
    echo "Internet is not available."
    exit 1
  }
  if [ -n "$old_pdf_name" ]; then
    if [ "$pdfname" = "$old_pdf_name" ]; then
      echo "Timetable has not changed." 
      exit 0 
    else
      echo "Timetable has updated."
      echo "deleteing old pdf: $old_pdf_name"
      rm "$timetable_dir/$old_pdf_name"
      echo "Downloading Timetable..."
    fi
  else
    echo "Old Pdf not found."
    echo "Downloading Timetable..."
  fi
  download_pdf && extract_page
  echo "Timetable Updated Successfully."
}

### Error Handeling ###
## check dependencies
check_deps 
## check if timetable_dir exists and is a directory
[ -d "$timetable_dir" ] || {
  echo "timetable_dir: $timetable_dir is not a valid directory."
  exit 2
}

### Argument Handling ###
case "$1" in
  -h|--help) help ;;
  get_pdfname) echo "$old_pdf_name";;
  update)
    pdfname=$(fetch_pdfname "$search_url")
    update_timetable
    ;;
  *) echo "error: invalid argument. use -h or --help for usage."; exit 4 ;;
esac
