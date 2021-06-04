gerrit() {
  ssh -p $(jq -r .port ~/.config/gerrit/gerrit.json) \
      -l $(jq -r .username ~/.config/gerrit/gerrit.json) \
      $(jq -r .host.ssh ~/.config/gerrit/gerrit.json) gerrit "${@}"
}

# gerrit rest api access
# first argument an be used to specify the method, if it is not GET POST or PUT
# it will be interpreted as URL
grest() {
    local host
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
    host="$(jq -r .host.web ~/.config/gerrit/gerrit.json)"
    username="$(jq -r .username ~/.config/gerrit/gerrit.json)"
    password="$(jq -r .password ~/.config/gerrit/gerrit.json)"
    shift
    http --auth-type basic                                                    \
         --auth "${username}:${password}"                                     \
         ${method}                                                            \
         ${host}${url}                                                        \
         "${@}"
}

gerrit_build_this() {
    gerrit_post_message -m "BUILD_THIS"
}

gerrit_change_id_head()
{
    git log -n 1 | awk '$1 ~ /Change-Id:/ { print $2 }' | tr -d '\n'
}

# Get current change ids
#
# Usage:
#   gerrit_current_change_ids [-b <base-commit>]
#
#   -b defaults to remote head
gerrit_current_change_ids() {
    git_dir="$(git rev-parse --show-toplevel)"
    local base_commit=""

    local opts OPTIND OPTARG
    while getopts ":b:" opts; do
        case "${opts}" in
            b)
                base_commit="${OPTARG}"
                ;;
            *)
                echo "Invalid argument: ${opts}" >&2
                return 1
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    if [ -z "${base_commit}" ]; then
        # remote branch
        gerrit_branch="$(grep "^defaultbranch=" "${git_dir}/.gitreview" | cut -d = -f 2)"
        gerrit_remote="$(grep "^defaultremote=" "${git_dir}/.gitreview" | cut -d = -f 2)"

        gerrit_remote_raw=$(git config --local remote.${gerrit_remote}.url)
        elements=("${(@s:/:)gerrit_remote_raw}")
        gerrit_project=${elements[-1]}
        elements[-1]=()
        gerrit_url=${(j./.)elements}

        elements=("${(@s.:.)gerrit_url}")
        gerrit_port=${elements[-1]}
        gerrit_url=${${elements[-2]}:gs./.}

        base_commit="${gerrit_remote}/${gerrit_branch}"
    fi
    change_ids=( "${(@f)$(git log ${base_commit}..HEAD \
        | awk '$1 ~ /^Change-Id:/ { print $2 }')}" )

    printf "%s\n" "${change_ids[@]}"
}

# Check if the last patch level of any open changeset was last uploaded by someone else.
#
# This should make it harder to accidentally overwrite other peoples edits.
gerrit_check_pre_review() {
    git_dir="$(git rev-parse --show-toplevel)"
    # remote branch
    gerrit_branch="$(grep "^defaultbranch=" "${git_dir}/.gitreview" | cut -d = -f 2)"
    gerrit_remote="$(grep "^defaultremote=" "${git_dir}/.gitreview" | cut -d = -f 2)"

    gerrit_remote_raw=$(git config --local remote.${gerrit_remote}.url)
    elements=("${(@s:/:)gerrit_remote_raw}")
    gerrit_project=${elements[-1]}
    elements[-1]=()
    gerrit_url=${(j./.)elements}

    elements=("${(@s.:.)gerrit_url}")
    gerrit_port=${elements[-1]}
    gerrit_url=${${elements[-2]}:gs./.}
    change_ids=( "${(@f)$(gerrit_current_change_ids)}" )
    committers=( "${(@f)$(git log --format="%cn <%ce>" "${gerrit_remote}/${gerrit_branch}..HEAD")}" )

    if (( ${#change_ids} != ${#committers} )); then
        echo "Not all commits in question have Change-Ids!" >&2
        return 1
    fi

    gerrit_username="${${gerrit_url##ssh://}%%@*}"

    tmpfile_change_info="$(mktemp)"

    for ((i = 1; i <= ${#change_ids}; i++)); do
        change_id="${change_ids[$i]}"
        committer="${committers[$i]}"

        ssh -p ${gerrit_port} ${gerrit_url} \
            "gerrit query project:${gerrit_project} change:${change_id} status:open --current-patch-set --format JSON" \
            | head -n 1 > "${tmpfile_change_info}"
        uploader_name="$(jq -r ".currentPatchSet.uploader.name" < "${tmpfile_change_info}")"
        uploader_mail="$(jq -r ".currentPatchSet.uploader.email" < "${tmpfile_change_info}")"
        change_url="$(jq -r ".url" < "${tmpfile_change_info}")"

        uploader="${uploader_name} <${uploader_mail}>"

        if [[ "${uploader}" == "null <null>" ]]; then
            echo "WARNING: Info on changeset ${change_id} not current anymore! Fetch from review!" >&2
        fi

        if [[ "${committer}" != "${uploader}" ]]; then
            echo "WARNING: [${change_url}] Committers differ! Local: ${committer} / Gerrit: ${uploader}" >&2
        fi
    done
    rm "${tmpfile_change_info}"
}

gerrit_checkout() {
    changenum="$(git review -l | grep "^\s*[0-9]" | fzf | awk '{ print $1 }')"

    if [ -n "${changenum}" ]; then
        git review -d "${changenum}"
    fi
}

gerrit_cherrypick() {
    changenums=( "${(@f)$(git review -l | grep "^\s*[0-9]" | fzf --multi | awk '{ print $1 }')}" )

    for num in "${changenums[@]}"; do
        if [ -n "${num}" ]; then
            git review -x "${num}" || return 1
        fi
    done
}

# Fetch all open changesets and assign them their own branch:
# gerrit_tree_view/{change number}/{patchset level}
gerrit_fetch_changesets() {
    git_dir="$(git rev-parse --show-toplevel)"
    # remote branch
    gerrit_remote="$(grep "^defaultremote=" "${git_dir}/.gitreview" | cut -d = -f 2)"
    localbranchname=gerrit_tree_view

    gerrit_remote_raw=$(git config --local remote.${gerrit_remote}.url)
    elements=("${(@s:/:)gerrit_remote_raw}")
    gerrit_project=${elements[-1]}
    elements[-1]=()
    gerrit_url=${(j./.)elements}

    elements=("${(@s.:.)gerrit_url}")
    gerrit_port=${elements[-1]}
    gerrit_url=${${elements[-2]}:gs./.}

    git branch -D $(git branch | grep "$localbranchname") &> /dev/null
    ssh -p ${gerrit_port} ${gerrit_url} gerrit query "project:${gerrit_project} status:open" --current-patch-set | sed -n 's/\s*ref: //p' | while read REF
do
    git fetch "${gerrit_remote}" "${REF}"
    git branch $(echo "${REF}" | sed "s#refs/changes/../#${localbranchname}/#") FETCH_HEAD
done
}

gerrit_get_changes() {
    grest "/a/changes/?q=$*"  | tail -n +2 | jq -r "map(.id) | .[]"
}

# Modify hashtags on the given change_id (-c)
#
# If change id is not specified, take the current head.
#
# Args:
#   -c change_id
#   [-a <hashtag to add>...]
#   [-r <hashtag to remove>...]
gerrit_hashtags() {
    local change_id
    local -a add
    local -a remove
    local -a args
    local opts OPTIND OPTARG
    change_id="head"
    while getopts ":c:a:r:" opts; do
        case "${opts}" in
            c)
                change_id="${OPTARG}"
                ;;
            a)  add+=("${OPTARG}")
                ;;
            r)  remove=+("${OPTARG}")
                ;;
            *)
                echo "Invalid argument: ${opts}" >&2
                return 1
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    if [ "${change_id}" = "head" ]; then
        change_id="$(gerrit_change_id_head)"
    fi

    args=( POST "/a/changes/${change_id}/hashtags" )

    if [ -n "${add[*]}" ] && [ -n "${remove[*]}" ]; then
        echo "ERROR: No hashtags given." >&2
        exit 1
    fi

    if [ -n "${add[*]}" ]; then
        local add_inner="$(printf '"%s", ' "${add[@]}")"
        args+=( "add:=[${add_inner%%, }]" )
    fi

    if [ -n "${remove[*]}" ]; then
        local remove_inner="$(printf '"%s", ' "${remove[@]}")"
        args+=( "remove:=[${remove_inner%%, }]" )
    fi

    grest "${args[@]}"
}

# Post a message (-m) to the given change_id (-c)
#
# If change id is not specified, take the current head.
#
# Args:
#   -c change_id
#   -l labels
#   -m message
gerrit_post_message() {
    local change_id
    local message
    local labels
    local -a args
    local opts OPTIND OPTARG
    change_id="head"
    message=""
    while getopts ":c:l:m:" opts; do
        case "${opts}" in
            c)
                change_id="${OPTARG}"
                ;;
            m)  message="${OPTARG}"
                ;;
            l)  labels="${OPTARG}"
                ;;
            t)  topic="${OPTARG}"
                ;;
            *)
                echo "Invalid argument: ${opts}" >&2
                return 1
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    if [ "${change_id}" = "head" ]; then
        change_id="$(gerrit_change_id_head)"
    fi

    args=( POST "/a/changes/${change_id}/revisions/current/review" )

    if [ -n "${message}" ]; then
        args+=( "message=${message}" )
    fi

    if [ -n "${labels}" ]; then
        args+=( "labels:=${labels}" )
    fi

    grest "${args[@]}"
}

gerrit_query() {
    local git_dir gerrit_branch gerrit_remote gerrit_host gerrit_port gerrit_project

    git_dir="$(git rev-parse --show-toplevel)"

    gerrit_branch="$(grep "^defaultbranch=" "${git_dir}/.gitreview" | cut -d = -f 2)"
    gerrit_remote="$(grep "^defaultremote=" "${git_dir}/.gitreview" | cut -d = -f 2)"
    gerrit_host="$(grep "^host=" "${git_dir}/.gitreview" | cut -d = -f 2)"
    gerrit_port="$(grep "^port=" "${git_dir}/.gitreview" | cut -d = -f 2)"
    gerrit_project="$(grep "^project=" "${git_dir}/.gitreview" | cut -d = -f 2)"

    ssh -p ${gerrit_port} ${gerrit_host} gerrit query "${@}"
}


# Set a topic (-t) on the given change_id (-c)
#
# If change id is not specified, take the current head.
#
# Args:
#   -c change_id
#   -t topic
gerrit_set_topic() {
    local change_id
    local topic
    local -a args
    local opts OPTIND OPTARG
    change_id="head"
    message=""
    while getopts ":c:t:" opts; do
        case "${opts}" in
            c)
                change_id="${OPTARG}"
                ;;
            t)  topic="${OPTARG}"
                ;;
            *)
                echo "Invalid argument: ${opts}" >&2
                return 1
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    if [ "${change_id}" = "head" ]; then
        change_id="$(gerrit_change_id_head)"
    fi

    args=( PUT "/a/changes/${change_id}/topic" )

    if [ -n "${topic}" ]; then
        args+=( "topic=${topic}" )
    else
        echo "ERROR: -t not provided!" >&2
        exit 1
    fi

    grest "${args[@]}"
}


