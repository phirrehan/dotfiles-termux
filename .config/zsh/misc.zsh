# ======= Functions =======
function docker-reload() {
  docker compose down --rmi local && docker compose up
}

function pacf() {
  pacman -Slq | fzf --multi --preview 'pacman -Si {1}' \
  --preview-window=wrap,border-sharp | xargs -ro sudo pacman -S
}

function pacrm() {
  pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' \
  --preview-window=wrap,border-sharp | xargs -ro sudo pacman -Rns
}

function paruf() {
  yay -Slq | fzf --multi --preview 'yay -Si {1}' \
  --preview-window=wrap,border-sharp | xargs -ro paru -S
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
