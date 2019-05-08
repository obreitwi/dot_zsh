# source /etc/profile
source $HOME/.zsh/rc_functions

ENCHOST=$(mdh)

[[ -f ~/.zsh/hosts/zprofile_pre_$ENCHOST ]] && source ~/.zsh/hosts/zprofile_pre_$ENCHOST

# source  autojump
[[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
# if there is a local version, source it as well
[[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && source ~/.autojump/etc/profile.d/autojump.zsh

[[ -d $HOME/.autojump ]] && prepend_root $HOME/.autojump

if command -v lsb_release 2>&1 >/dev/null; then
    DISTNAME=$(lsb_release -c -s)
    if [ "${DISTNAME}" != "n/a" ]; then
        prepend_root $HOME/.local-${DISTNAME}
    fi
fi

# prepend_root $HOME/usr
prepend_root $HOME/.local

[[ -f ~/.zsh/hosts/zprofile_$ENCHOST ]] && source ~/.zsh/hosts/zprofile_$ENCHOST

# vim: ft=zsh
