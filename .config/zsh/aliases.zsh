# System
alias ls="ls --color=auto"
alias Ls="ls -A --color=auto"
alias grep="grep --color=auto"
alias c="clear"

# Package Management
alias i="nala update && nala install $1"
alias rem="nala remove $1"
alias s="nala search $1"
alias u="nala update && nala upgrade"

# Zsh Config
alias svim="sudo -E nvim"
alias sz="source ~/.zshrc"


# Global Aliases
alias -g C="| termux-clipboard-set"

# Suffix Aliases
alias -s pdf='termux-open'
alias -s png='termux-open'
alias -s jpeg='termux-open'
alias -s jpg='termux-open'
alias -s mp4='termux-open'
alias -s mkv='termux-open'
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
