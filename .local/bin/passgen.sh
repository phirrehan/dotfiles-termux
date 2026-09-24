#!/data/data/com.termux/files/usr/bin/sh

export PASSWORD_STORE_DIR="$HOME/files/Passwords/store"

auth_token="$1"
passName="$2"
passLength="$3"

# Require authentication token.
[ -z "$auth_token" ] && exit 1

# Require password name.
[ -z "$passName" ] && {
  echo "Error: password name is required" >&2
  exit 2
}

# Default length.
[ -z "$passLength" ] && passLength=20

# Check length.
case "$passLength" in
*[!0-9]*)
  echo "Error: invalid input. expected a number" >&2
  exit 3
  ;;
esac

[ "$passLength" -le 0 ] && {
  echo "Error: invalid input. expected a number greater than 0" >&2
  exit 4
}

passDir=$(
  ls "$PASSWORD_STORE_DIR" |
    fzf \
      --pointer '=>' \
      --layout reverse \
      --info hidden \
      --header 'Select a Directory' \
      2>/dev/null
)
[ -z "$passDir" ] && exit 5

# Generate password.
password=$(
  pass generate -f "$passName" "$passLength" |
    awk 'NR==2 { gsub(/\x1B\[[0-9;]*[[:alpha:]]/, ""); printf "%s", $0 }'
)

[ -z "$password" ] && exit 6

# Move password
pass mv "$passName" "$passDir/" >/dev/null

echo "Sending generated password to PassIme..." >&2

am broadcast \
  -n com.example.passime/.PasswordReceiver \
  -a com.example.passime.PASSWORD \
  --es token "$auth_token" \
  --es password "$password"

exit $?
