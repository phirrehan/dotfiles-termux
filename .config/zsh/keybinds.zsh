# ======= Widgets =======
# Copy Command 
copy-command() { 
  echo -n "$BUFFER" | wl-copy
  zle -M "Copied to Clipboard"
}

# Add zle widgets
zle -N copy-command
autoload -Uz edit-command-line
zle -N edit-command-line


# ======= KeyBinds =======
# Set Emacs Mode
bindkey -e

# Key Binds
bindkey "^Xy" copy-command
bindkey "^[n" edit-command-line
bindkey -s "^O" 'cd ..\n'
