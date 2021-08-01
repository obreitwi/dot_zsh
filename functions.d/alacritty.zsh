export_terminfo_alacritty() {
    if (( $# == 0 )); then
        echo "Need to specify host" >&2
        return 1
    fi
    local host="$1"
    if (( $( find /usr/share/terminfo/a -type f -name "alacritty*" | wc -l) )); then
        tar c /usr/share/terminfo/a/alacritty*  | ssh "${host}" "([ ! -d .terminfo/a ] && mkdir -vp .terminfo/a) && cd .terminfo/a && tar vx -f - --strip-components=4"
    else
        echo "Error: Alacritty terminfo not found!" >&2
    fi
}

