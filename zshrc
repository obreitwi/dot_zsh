# reclaim ctrl-s
stty stop undef
stty start undef

if [ -z "${ZSH_CFG_ROOT:-}" ]; then
    ZSH_CFG_ROOT="$(dirname "$(readlink -m "${(%):-%N}")")"
    export ZSH_CFG_ROOT
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $ZSH_CFG_ROOT/rc_functions
ENCHOST=$(mdh)

# host specific configs that have to be loaded before anything else
[ -f "$ZSH_CFG_ROOT/hosts/pre_$ENCHOST" ] && source "$ZSH_CFG_ROOT/hosts/pre_$ENCHOST"

source "$ZSH_CFG_ROOT/main"
source "$ZSH_CFG_ROOT/variables"
source "$ZSH_CFG_ROOT/prompt"
source "$ZSH_CFG_ROOT/plugins/init.zsh" # needs to be after main to avoid double escaping spaces in filename completions
source "$ZSH_CFG_ROOT/lscolors"
source "$ZSH_CFG_ROOT/functions"
source "$ZSH_CFG_ROOT/aliases"
source "$ZSH_CFG_ROOT/widgets"

if zvm_available; then
    function zvm_after_lazy_keybindings() {
        source "$ZSH_CFG_ROOT/bindkeys"
    }
else
    source "$ZSH_CFG_ROOT/bindkeys"
fi
source "$ZSH_CFG_ROOT/tools"
source "$ZSH_CFG_ROOT/term"

if [ -e "$ZSH_CFG_ROOT/private" ]; then
    source "$ZSH_CFG_ROOT/private"
fi

# load fasd if it exists
command -v fasd &> /dev/null && source =(fasd --init auto)
# # source  autojump
# [[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
# # if there is a local version, source it as well
# [[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && source ~/.autojump/etc/profile.d/autojump.zsh

# check for host specific configs
[ -f "$ZSH_CFG_ROOT/hosts/$ENCHOST" ] && source "$ZSH_CFG_ROOT/hosts/$ENCHOST"

# source $HOME/.zsh/completion/*.zsh_completion

# finally load gmrl zshrc - now only used for neat little functions
#  source $HOME/.zsh/zshrc_grml

source "$ZSH_CFG_ROOT/variables_postrc"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f "$ZSH_CFG_ROOT/p10k/p10k.zsh" ]] || source "$ZSH_CFG_ROOT/p10k/p10k.zsh"
