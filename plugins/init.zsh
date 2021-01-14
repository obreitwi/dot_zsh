#!/usr/bin/env zsh

dir_plugins=${${0:A}:h}

if which fzf >/dev/null && [ -d "${dir_plugins}/fzf-tab" ]; then
    # NOTE: fzf-tab needs to be loaded after compinit, but before plugins which
    # will wrap widgets like zsh-autosuggestions or fast-syntax-highlighting.
    source "${dir_plugins}/fzf-tab/fzf-tab.plugin.zsh"
    zstyle ":completion:*:git-checkout:*" sort false
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    if which exa >/dev/null; then
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
    fi

    source "${dir_plugins}/fzf-fasd/fzf-fasd.plugin.zsh"

    # once tmux 3.2 is installed we could do:
    # zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi

source "${dir_plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh"
export ZSH_AUTOSUGGEST_USE_ASYNC=""

export FZF_FASD_OPTS='--prompt "fasd_cd> "'
source "${dir_plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# history-substring-search needs to come AFTER syntax-highlithing
source "${dir_plugins}/zsh-history-substring-search/zsh-history-substring-search.zsh"

# bindings for history-substring search
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

source "${dir_plugins}/zsh-autopair/autopair.zsh"
autopair-init
