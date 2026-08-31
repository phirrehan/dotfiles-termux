#!/data/data/com.termux/files/usr/bin/sh

fzf --prompt '󰮯 ' --layout reverse --info hidden --header '$1' --no-multi </proc/$$/fd/0 >/proc/$$/fd/1
