# create a new branch from any story
git-branch-backlog() { # [--rev|--jira] <args for rev-backlog>
    local id
    local arg_id="--rev"

    if (( $# > 0 )); then
        case "$1" in
            "-j"|"--jira")
                arg_id=--jira
                shift 1
                ;;
            "-r"|"--rev")
                arg_id=--rev
                shift 1
                ;;
        esac
    fi
    id=$(revcli backlog query "$@" "$arg_id")

    local branch
    if ! branch=$(git-branch-name); then
        return 1
    fi

    git checkout -b "ojb/$id/$branch" "origin/$(git-origin-name)"
}

git-branch-name() {
    local tmp=/tmp/git-branch-name
    local new_branch_name
    if new_branch_name=$(gum input --placeholder "branch name" --value "$([ -f "$tmp" ] && tr -d '\n' <"$tmp")"); then
        tee "$tmp" <<<"$new_branch_name"
    else
        return $?
    fi
}

# create a new branch
git-branch-story() { # [--rev|--jira]
    local id
    local arg_id="--rev"

    if (( $# > 0 )); then
        case "$1" in
            "-j"|"--jira")
                arg_id=--jira
                shift 1
                ;;
            "-r"|"--rev")
                arg_id=--rev
                shift 1
                ;;
        esac
    fi

    id=$(revcli stories "$arg_id")

    local branch
    if ! branch=$(git-branch-name); then
        return 1
    fi

    git checkout -b "ojb/$id/$branch" "origin/$(git-origin-name)"
}
alias gbs=git-branch-story

# create a new branch
git-branch-nostory() {
    local branch
    if ! branch=$(git-branch-name); then
        return 1
    fi

    git switch -c "ojb/nostory/$branch" "origin/$(git-origin-name)"
}
#
# create a new branch
git-story-open() {
    rev-backlog -j "$(git-branch-jira-id)" -w
}

