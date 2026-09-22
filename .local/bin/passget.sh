#!/data/data/com.termux/files/usr/bin/sh

export PASSWORD_STORE_DIR="$HOME/files/Passwords/store"

auth_token="$1"

# Require an authentication token.
[ -z "$auth_token" ] && exit 1

password_name=$(
  find "$PASSWORD_STORE_DIR" -type f -regex '.+\.gpg$' |
    sed "s|$PASSWORD_STORE_DIR||; s|\.gpg$||" |
    fzf \
      --pointer '=>' \
      --layout reverse \
      --info hidden \
      --header 'Select a Password' \
      2>/dev/null
)

# Exit if no password is selected.
[ -z "$password_name" ] && exit 1

# check if otp is selected
printf '%s' "$password_name" |
  grep -Eq '.+otp$' &&
  password_name="otp/$password_name" &&
  pass_args=("otp" "$password_name") || pass_args=("$password_name")

# Run pass interactively.
password=$(pass "${pass_args[@]}") || exit 1

echo "Sending password to PassIme..." >&2

am broadcast \
  -n com.example.passime/.PasswordReceiver \
  -a com.example.passime.PASSWORD \
  --es token "$auth_token" \
  --es password "$password"

broadcast_status=$?

echo "Broadcast exit status: $broadcast_status" >&2

exit "$broadcast_status"
