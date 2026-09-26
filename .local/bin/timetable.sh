#!/data/data/com.termux/files/usr/bin/bash

set -u

kind="class"
department="CS"
section="SP25-BSE-A"

termux_prefix="/data/data/com.termux/files/home"
timetable_dir="$termux_prefix/storage/downloads/timetable"

url="https://sfs.cuilahore.edu.pk/schedule/Public/Timetable?Kind=$kind&Dept=$department&Who=$section"

html_file="$(mktemp)"
new_pdf="$timetable_dir/.new-timetable.pdf"
chromium_bin="chromium-browser"

cleanup() {
  rm -f "$html_file" "$new_pdf"
}
trap cleanup EXIT

mkdir -p "$timetable_dir" || {
  echo "Could not create timetable directory."
  exit 1
}

ping -c 1 github.com &>/dev/null || {
  echo "Internet is not available."
  exit 1
}

command -v "$chromium_bin" &>/dev/null || {
  echo "Could not find chromium-browser."
  exit 1
}

curl -sk "$url" -o "$html_file" || {
  echo "Failed to download timetable HTML."
  exit 2
}

version_date=$(
  grep -oE 'v\.[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$html_file" |
    head -n 1 |
    grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}'
)

if [ -z "$version_date" ]; then
  echo "Could not find timetable version date in HTML."
  exit 3
fi

old_pdf=""

for file in "$timetable_dir"/*.pdf; do
  [ -f "$file" ] || continue
  old_pdf="$file"
  break
done

old_pdf_date=""

if [ -n "$old_pdf" ]; then
  old_pdf_name="$(basename "$old_pdf")"
  old_pdf_date=$(
    printf '%s\n' "$old_pdf_name" |
      grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}(?=\.pdf$)' |
      tail -n 1
  )
fi

if [ -n "$old_pdf" ] &&
  [ -n "$old_pdf_date" ] &&
  [ "$old_pdf_date" = "$version_date" ]; then
  echo "Timetable has not changed."
  exit 0
fi

pdfname="${section}-${version_date}.pdf"
pdf_path="$timetable_dir/$pdfname"

echo "Timetable has updated."
echo "Generating $pdfname..."

"$chromium_bin" \
  --headless \
  --no-sandbox \
  --disable-gpu \
  --print-to-pdf="$new_pdf" \
  "$url" \
  >/dev/null 2>&1

if [ $? -ne 0 ] || [ ! -s "$new_pdf" ]; then
  echo "Download failed."
  exit 4
fi

if ! head -c 5 "$new_pdf" | grep -q '^%PDF-'; then
  echo "Invalid PDF generated."
  exit 5
fi

mv "$new_pdf" "$pdf_path" || {
  echo "Could not save PDF."
  exit 6
}

if [ -n "$old_pdf" ] && [ "$old_pdf" != "$pdf_path" ]; then
  rm -f "$old_pdf"
fi

echo "Timetable successfully updated."
echo "Saved: $pdf_path"
