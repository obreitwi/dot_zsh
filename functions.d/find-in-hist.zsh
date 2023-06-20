find_in_hist() {
    if command -v ugrep &>/dev/null; then
        ugrep -zG "$@" ~/.logs
    else
        zgrep "$@" ~/.logs/*.gz
        grep -r "$@" ~/.logs
    fi
}
alias hif=find_in_hist

copy_from_history() {
    local -a args
    args=( "$@" )
    if (( ${#args} == 0 )); then
        args+=""
    fi
    ugrep -zG -I --no-filename "${args[@]}" ~/.logs | sed -e "s#^$USER@$HOST:.*\[[^]]*\]\s##g" | sort | uniq | fzf | xclip -i -selection clipboard
}
alias hic=copy_from_history
