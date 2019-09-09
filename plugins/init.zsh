#!/usr/bin/env zsh

dir_plugins=${${0:A}:h}

source ${dir_plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_USE_ASYNC=""

source ${dir_plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# history-substring-search needs to come AFTER syntax-highlithing
source ${dir_plugins}/zsh-history-substring-search/zsh-history-substring-search.zsh

# bindings for history-substring search
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
