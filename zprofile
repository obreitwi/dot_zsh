
source ~/.zsh/rc_functions

ENCHOST=$(mdh)

if command -v lsb_release 2>&1 >/dev/null; then
    DISTNAME=$(lsb_release -c -s)
    prepend_root $HOME/.local-$DISTNAME
fi

# prepend_root $HOME/usr
prepend_root $HOME/.local

[ -f ~/.zsh/hosts/zprofile_$ENCHOST ] && source ~/.zsh/hosts/zprofile_$ENCHOST ]

