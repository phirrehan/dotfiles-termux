if [ -n "$TERMUX_VERSION" ]; then
  # Termux Aliases
  alias i="nala update && nala install $1"
  alias rem="nala remove $1"
  alias s="nala search $1"
  alias u="nala update && nala upgrade"
  alias c="clear"
fi

# System
alias ls="ls --color=auto"
alias Ls="ls -A --color=auto"
alias grep="grep --color=auto"
alias change="cat ~/.local/state/caelestia/sequences.txt"

# Zsh Config
alias svim="sudo -E nvim"
alias sz="source ~/.zshrc"


# Global Aliases
alias -g C="| wl-copy"

# Suffix Aliases
alias -s pdf='mupdf'
alias -s png='gwenview'
alias -s jpeg='gwenview'
alias -s jpg='gwenview'
alias -s mp4='mpv'
alias -s mkv='mpv'
alias -s md='bat'
alias -s yaml='bat -l'
alias -s json='jless'
alias -s c='$EDITOR'
alias -s cpp='$EDITOR'
alias -s java='$EDITOR'
alias -s go='$EDITOR'
alias -s py='$EDITOR'
alias -s conf='$EDITOR'
alias -s zsh='$EDITOR'
alias -s zshrc='$EDITOR'
alias -s zprofile='$EDITOR'
