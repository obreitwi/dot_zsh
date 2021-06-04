jrest() {
    local method
    local url
    local username
    local password
    method=$1
    if [[ "${(U)method}" =~ "^(GET|PUT|POST|DELETE)$" ]]; then
        shift
    else
        # first argument only contains URL
        method=""
    fi
    url=$1
    host="$(jq -r .url ~/.config/jenkins/jenkins.json)"
    username="$(jq -r .username ~/.config/jenkins/jenkins.json)"
    token="$(jq -r .token ~/.config/jenkins/jenkins.json)"
    shift
    http --auth-type basic                                                   \
         --auth "${username}:${token}"                                       \
         ${method}                                                           \
         ${host}${url}                                                       \
         "${@}"
}

# Usage:
#   jenkins_get_log [-a <artifact>] <project>[/][<build number>]
#
#   Fetches and echoes the name of the file in which the log is present. Log
#   will only be fetched if logfile does not exist.
#
#   Can then be used like this: nvim $(jenkins_get_log my-fancy-jobname).
#
#   See also: jenkins_view_log
#
# Args:
#   -a <artifact>   Get specific artifact (example: errors_concretization.log).
#
#   -f              Force redownload of log even if it exists.
#
#   <project>       Project to fetch
#
#   <build number>  Log from which build to get [default: latest]. Can be set
#                   to -n to get the n-th latest build log.
#
jenkins_get_log() {
    local project
    local build_num
    local logname
    local artifact
    local force
    local latest_build
    local opts OPTIND OPTARG
    artifact=""
    force=0

    while getopts ":a:f" opts; do
        case "${opts}" in
            a)
                artifact="${OPTARG}"
                ;;
            f)  force=1
                ;;
            *)
                echo "Invalid argument: ${opts}" >&2
                return 1
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    if (( $# > 0 )); then
        local proj_arr
        proj_arr=( "${(s./.)1}" )
        project="${proj_arr[1]}"
        if (( ${#proj_arr} > 1 )); then
            build_num="${proj_arr[2]}"
        fi
    else
        echo "Need to specify project!" &>2
        return 1
    fi
    shift

    if (( $# > 0 )); then
        build_num="$1"
        shift
    fi

    if [ -n "${build_num:-}" ]; then
        if (( build_num <= 0 )); then
            latest_build=$(jrest GET /job/${project}/api/json | jq ".builds | .[0] | .number")
            build_num=$(( latest_build + build_num ))
        fi
    else
        build_num=$(jrest GET /job/${project}/api/json | jq ".builds | .[0] | .number")
    fi
    if (( ${#artifact} > 0 )); then
        logname="${TMPDIR:-/tmp}/${project}_${build_num}_${artifact}"
    else
        logname="${TMPDIR:-/tmp}/${project}_${build_num}.log"
    fi

    if [ ! -f "${logname}" ] || (( force != 0 )); then
        if (( ${#artifact} > 0 )); then
            jrest GET "/job/${project}/${build_num}/artifact/${artifact}" > "${logname}" || rm ${logname}
        else
            jrest GET "/job/${project}/${build_num}/consoleText" > "${logname}"
        fi
    fi
    echo "${logname}"
}

# Usage:
#   jenkins_view_log [-a <artifact>] <project>[/][<build number>]
#
#   Fetches and opens the specified jenkins log in $EDITOR. Log will only be
#   fetched if logfile does not exist.
#
# Args:
#   -a <artifact>   Get specific artifact (example: errors_concretization.log).
#
#   -f              Force redownload of log even if it exists.
#
#   <project>       Project to fetch
#
#   <build number>  Log from which build to get [default: latest]. Can be set
#                   to -n to get the n-th latest build log.
#
jenkins_view_log() {
    ${EDITOR} $(jenkins_get_log "${@}")
}
