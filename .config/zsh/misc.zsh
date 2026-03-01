# ======= Functions =======
function docker-reload() {
  docker compose down --rmi local && docker compose up
}

function nalaf() {
  apt-cache pkgnames | \
  fzf --height=40% --layout=reverse --multi --preview 'nala show {1}' \
      --preview-window=wrap,border-sharp | \
  xargs -ro nala install
}

function nalar() {
  dpkg-query -f '${binary:Package}\n' -W | \
  fzf --height=40% --layout=reverse --multi --preview 'nala show {1}' \
      --preview-window=wrap,border-sharp | \
  xargs -ro nala purge
}

# ======= chpwd hook =======
_auto_venv() {
  if [[ -d .venv ]]; then
    source .venv/bin/activate
  elif [[ -d venv ]]; then
    source venv/bin/activate
  elif [[ -n "$VIRTUAL_ENV" ]]; then
    deactivate
  fi
}

chpwd() {
  _auto_venv
}
