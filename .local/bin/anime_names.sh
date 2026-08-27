#!/bin/sh

curl -s 'https://api.jikan.moe/v4/seasons/now' |
  jq -r '.data[].title_english // .data[].title' >"$HOME/.local/state/anime/list.txt"
