#!/usr/bin/env zsh

dir_plugins=${${0:A}:h}

zvm_available() {
    [ -f /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]
}

if zvm_available; then
    source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
else
    zvm_after_init_commands=()
fi

if command -v fzf >/dev/null && [ -d "${dir_plugins}/fzf-tab" ]; then
    # NOTE: fzf-tab needs to be loaded after compinit, but before plugins which
    # will wrap widgets like zsh-autosuggestions or fast-syntax-highlighting.
    source "${dir_plugins}/fzf-tab/fzf-tab.plugin.zsh"

    zstyle ":completion:*:git-checkout:*" sort false
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    if command -v exa >/dev/null; then
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
    fi

    if command -v fasd >/dev/null; then
        export FZF_FASD_OPTS='--prompt "fasd_cd> "'
        source "${dir_plugins}/fzf-fasd/fzf-fasd.plugin.zsh"
    fi

    FORGIT_FZF_DEFAULT_OPTS="--preview-window 'down:75%'"
    export FORGIT_FZF_DEFAULT_OPTS
    source "${dir_plugins}/forgit/forgit.plugin.zsh"

    # once tmux 3.2 is installed we could do:
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

    # resolve issue with carapace
    zstyle ':fzf-tab:*' query-string prefix first
fi

source "${dir_plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh"
export ZSH_AUTOSUGGEST_USE_ASYNC=""

source "${dir_plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# history-substring-search needs to come AFTER syntax-highlithing
source "${dir_plugins}/zsh-history-substring-search/zsh-history-substring-search.zsh"

# bindings for history-substring search
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

source "${dir_plugins}/zsh-autopair/autopair.zsh"
autopair-init
