# ======= Functions =======
function docker-reload() {
  docker compose down --rmi local && docker compose up
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
