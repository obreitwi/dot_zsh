
source $HOME/.zsh/rc_functions
ENCHOST=$(mdh)

# host specific configs that have to be loaded before anything else
[ -f ~/.zsh/hosts/pre_$ENCHOST ] && source ~/.zsh/hosts/pre_$ENCHOST

if [ -d ~/.oh-my-zsh ]; then
    source $HOME/.zsh/oh-my-zshrc
else
    source $HOME/.zsh/plugins/init.zsh
    source $HOME/.zsh/main
    source $HOME/.zsh/variables
    source $HOME/.zsh/prompt
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
    type fasd &> /dev/null && source =(fasd --init auto)
    # # source  autojump
    # [[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
    # # if there is a local version, source it as well
    # [[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && source ~/.autojump/etc/profile.d/autojump.zsh

    # check for host specific configs
    [ -f ~/.zsh/hosts/$ENCHOST ] && source ~/.zsh/hosts/$ENCHOST

    # source $HOME/.zsh/completion/*.zsh_completion

    # finally load gmrl zshrc - now only used for neat little functions
    #  source $HOME/.zsh/zshrc_grml

fi

source /home/obreitwi/.config/broot/launcher/bash/br
