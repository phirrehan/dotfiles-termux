# System
alias ls="eza --icons --group-directories-first"
alias Ls="eza -A --icons --group-directories-first"
alias grep="grep --color=auto"
alias c="clear"
alias login="proot-distro login --user rehan archlinuxarm --shared-tmp"

# Package Management
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
