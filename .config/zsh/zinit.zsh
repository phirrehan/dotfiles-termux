# Zinint

# Source Zinit
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Add in Zsh Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# History
HISTSIZE=5000
HISTFILE=~/.cache/zsh/history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Load completions
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
_anime() {
    local -a suggestions

    suggestions=("${(@f)$(< ~/.local/state/anime/list.txt)}")

    compadd -M 'm:{a-z}={A-Z}' -- "${suggestions[@]}"
}
compdef _anime ani-cli
zinit cdreplay -q

# Enable colors and change prompt:
PS1="%B% %{$fg[yellow]%}%~%{$reset_color%} ◎%b "
 
# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Shell Integrations
eval "$(fzf --zsh)"
