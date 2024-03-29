# reclaim ctrl-s
stty stop undef
stty start undef

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/.zsh/rc_functions
ENCHOST=$(mdh)

# host specific configs that have to be loaded before anything else
[ -f ~/.zsh/hosts/pre_$ENCHOST ] && source ~/.zsh/hosts/pre_$ENCHOST

if [ -d ~/.oh-my-zsh ]; then
    source $HOME/.zsh/oh-my-zshrc
else
    source $HOME/.zsh/main
    source $HOME/.zsh/variables
    source $HOME/.zsh/prompt
    source $HOME/.zsh/plugins/init.zsh # needs to be after main to avoid double escaping spaces in filename completions
    source $HOME/.zsh/lscolors
    source $HOME/.zsh/functions
    source $HOME/.zsh/aliases
    source $HOME/.zsh/widgets

    if zvm_available; then
        function zvm_after_lazy_keybindings() {
            source $HOME/.zsh/bindkeys
        }
    else
        source $HOME/.zsh/bindkeys
    fi
    source $HOME/.zsh/tools
    source $HOME/.zsh/term

    if [ -e $HOME/.zsh/private ]; then
        source $HOME/.zsh/private
    fi

    # load fasd if it exists
    command -v fasd &> /dev/null && source =(fasd --init auto)
    # # source  autojump
    # [[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
    # # if there is a local version, source it as well
    # [[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && source ~/.autojump/etc/profile.d/autojump.zsh

    # check for host specific configs
    [ -f ~/.zsh/hosts/$ENCHOST ] && source ~/.zsh/hosts/$ENCHOST

    # source $HOME/.zsh/completion/*.zsh_completion

    # finally load gmrl zshrc - now only used for neat little functions
    #  source $HOME/.zsh/zshrc_grml

    source $HOME/.zsh/variables_postrc
    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

fi
