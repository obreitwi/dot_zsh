# container utility functions
# Usage:
#   launch_container [options] [<app>] [<image>]
launch_container() {
    local image
    local app

    local args
    args=("shell" "-s" "/bin/zsh")

    local getent_home
    getent_home=$(getent passwd $USER | cut -d: -f6)

    # if current $HOME differs from getent value, set it
    if [ "${HOME}" != "${getent_home}" ]; then
        args+=("-H" "${HOME}")
    fi

    args+=("-B" "/run")

    if (( $# > 0 )); then
        app="${1}"
        args+=("--app" "${app}")
        shift
    fi
    image="${1:-$(readlink -f ${MY_DEFAULT_CONTAINER:-/containers/stable/latest})}"

    singularity "${args[@]}" "${image}"
}

alias runcon="launch_container"

condev() {
    launch_container visionary-dev-tools "${@}"
}

conwaf() {
    launch_container visionary-wafer "${@}"
}

condls() {
    launch_container visionary-dls "${@}"
}
