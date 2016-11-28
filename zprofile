# get md5sum of hostname
mdh() {
    if [[ $# == 0 ]]; then
        input=$HOST
    else
        input=$1
    fi
    echo $(set -- $(echo "$input" | md5sum -); echo $1)
}
ENCHOST=$(mdh)

[ -f ~/.zsh/hosts/zprofile_$ENCHOST ] && source ~/.zsh/hosts/zprofile_$ENCHOST ]

