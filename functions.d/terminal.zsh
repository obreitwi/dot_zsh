# Usage:
#   wait_pid [-i <interval>] <pid>
#
# Wait for the given PID in intervals of length <interval>s.
wait_pid() {
    local pid
    local interval
    interval=1
    while getopts ":i:" opts; do
        case "${opts}" in
            i)
                interval="${OPTARG}"
                ;;
            *)
                echo "Invalid argument: ${opts}" >&2
                return 1
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    if (( $# > 0 )); then
        pid="$1"
    else
        echo "No PID given.." >&2
        return 1
    fi
    echo -n "Waiting for PID: ${pid}" >&2

    while kill -0 ${pid} 2>/dev/null 1>/dev/null; do
        echo -n "."
        sleep "${interval}"
    done
}

# fzf-fasd integration
#
# Interactively insert recent directory
zd() {
    fasd -d -l -r "$1" | fzf --query="$1 " --select-1 --exit-0 --height=25% --reverse --tac --no-sort --cycle
}

