# ======= Functions =======
function nalaf() {
  apt-cache pkgnames | \
  fzf --prompt '󰮯 ' --height=40% --layout=reverse --multi --preview 'nala show {1}' \
      --preview-window=wrap,border-sharp | \
  xargs -ro nala install
}

function nalar() {
  dpkg-query -f '${binary:Package}\n' -W | \
  fzf --prompt '󰮯 ' --height=40% --layout=reverse --multi --preview 'nala show {1}' \
      --preview-window=wrap,border-sharp | \
  xargs -ro nala purge
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
