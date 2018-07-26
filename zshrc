
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
    source $HOME/.zsh/lscolors
    source $HOME/.zsh/functions
    source $HOME/.zsh/aliases
    source $HOME/.zsh/bindkeys
    if [ -e $HOME/.zsh/private ]; then
        source $HOME/.zsh/private
    fi

    # load fasd if it exists
    type fasd &> /dev/null && source =(fasd --init auto)
    # # source  autojump
    # [[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
    # # if there is a local version, source it as well
    # [[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && source ~/.autojump/etc/profile.d/autojump.zsh

    # support for 256 colors
    # export TERM='rxvt-256color'
    # (only load when we are in no tmux session)
    if [[ -z $TMUX ]]; then
        # if [[ -e /usr/share/terminfo/x/xterm-256color  ||  -e /lib/terminfo/x/xterm-256color ]]; then
            # export TERM='xterm-256color'
        # else
            # export TERM='xterm-color'
        # fi
        # if [[ -n $DISPLAY ]]; then
            # export TERM='rxvt-unicode-256color'
            # export LANG='en_US.UTF8'

        if [[ -z $TERM ]]; then
            infocmp rxvt-unicode-256color &>/dev/null
            if [[ $? -eq 0 ]]; then
                export TERM='rxvt-unicode-256color'
            else
                # export TERM='linux'
                # export LANG='en_US.iso88591'
                # export LANG='en_US.UTF8'
            fi
        fi
    else
        # will be set by tmux
        # export TERM='screen-256color'
    fi

    # check for host specific configs
    [ -f ~/.zsh/hosts/$ENCHOST ] && source ~/.zsh/hosts/$ENCHOST

    # source $HOME/.zsh/completion/*.zsh_completion

    # finally load gmrl zshrc - now only used for neat little functions
    #  source $HOME/.zsh/zshrc_grml
fi

