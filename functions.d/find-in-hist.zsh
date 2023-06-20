find_in_hist() {
    if command -v ugrep &>/dev/null; then
        ugrep -zG "$@" ~/.logs
    else
        zgrep "$@" ~/.logs/*.gz
        grep -r "$@" ~/.logs
    fi
}
alias hif=find_in_hist

get_from_history() {
    local -a args
    args=( "$@" )
    if (( ${#args} == 0 )); then
        args+=""
    fi
    get_history_lines_p0 \
        | ugrep -G -a "${args[@]}" \
        | sed -e "s#^$USER@$HOST:.*\[[^]]*\]\s##g" | sort | uniq | fzf | tr '\0' '\n'
}

# newlines within entries are 0-encoded
get_history_lines_p0() {
    {
        find ~/.logs -type f -name "*.log" | xargs -r cat
        find ~/.logs -type f -name "*.log.gz" | xargs -r zcat
    } | tr '\n' '\0' | sed -e "s#\x0$USER@$HOST#\n$USER@$HOST#g"
}

copy_from_history() {
    get_from_history "$@" | xclip -i -selection clipboard
}
alias hic=copy_from_history

insert-from-history() {
    local -a args
    # clear-line
    printf '\x1B[1K\r'
    args=( $(gum input --placeholder "Search in history" --prompt "❯ ") )
    BUFFER=$(get_from_history "${args[@]}")
}
