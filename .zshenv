# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_MUSIC_DIR="$HOME/Music"

# Zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Editor
export EDITOR="nvim"

# Used for scripts
export PASSWORD_STORE_DIR="$HOME/files/Passwords/store"

# Rust / Cargo
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Go
export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export GOCACHE="$XDG_CACHE_HOME/go-build"

# npm
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"

# Python
export PYTHONHISTFILE="$XDG_STATE_HOME/python/history"

# clang format
export CLANG_FORMAT_STYLE="$XDG_CACHE_HOME/clang/clang-format"

# git config
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"

# wine prefix
export WINEPREFIX="$XDG_DATA_HOME/wine"
