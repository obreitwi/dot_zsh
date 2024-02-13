
bb-current-project() {
    git remote get-url origin | awk -v FS=/ '{ print $(NF-1)}'
}

bb-current-repo() {
    git remote get-url origin | awk -v FS=/ '{ print $NF }' | sed "s:\.git$::"
}

bb-current-domain() {
    git remote get-url origin | awk -v FS=/ '{ print $3 }' | sed "s:^git@::"
}

bb-url-api_1() {
    echo "https://$(bb-current-domain)/rest/api/1.0/projects/$(bb-current-project)/repos/$(bb-current-repo)"
}

bb-url-api_latest() {
    echo "https://$(bb-current-domain)/rest/api/latest/projects/$(bb-current-project)/repos/$(bb-current-repo)"
}

bb-url-ui_latest() {
    echo "https://$(bb-current-domain)/rest/ui/latest/projects/$(bb-current-project)/repos/$(bb-current-repo)"
}

bb-user() {
    jq -r .user ~/.config/bitbucket/config.json
}

bb-get-raw() { # <endpoint>
    curl -s --show-error -H "authorization: Bearer $(cat ~/.config/bitbucket/cli.token)" "$1"
}

bb-get() { # <endpoint>
    bb-get-raw "$(bb-url-api_1)/$1"
}

bb-delete() { # <endpoint>
    curl -s --show-error -X DELETE -H "authorization: Bearer $(cat ~/.config/bitbucket/cli.token)" "$(bb-url-api_1)/$1"
}

bb-post() { # <endpoint>
    bb-post-raw "$(bb-url-api_1)/$1"
}

bb-post-raw() { # <URL>
    curl -s --show-error --json @- -H "authorization: Bearer $(cat ~/.config/bitbucket/cli.token)" "$1"
}

bb-post_latest() { # <endpoint>
    bb-post-raw "$(bb-url-api_latest)/$1"
}

bb-pr-current() {
    bb-get "pull-requests?at=$(git rev-parse --symbolic-full-name HEAD)&direction=OUTGOING&state=OPEN" | jq '.values[0]'
}

bb-pr-my() {
    bb-get "pull-requests?username.1=$(bb-user)&state=OPEN"
}

bb-pr-id() {
    bb-pr-current | jq '.id'
}

bb-pr-get-title() {
    jq -r '.title'
}

bb-pr-get-url() {
    jq -r ".links.self[0].href | select(. != null)" | tr -d '\n'
}

bb-pr-url() {
    bb-pr-current | bb-pr-get-url
}

bb-pr-md() {
   local pr
   pr=$(bb-pr-current)
   { printf "[%s](%s)" "$(bb-pr-get-title <<<"$pr")" "$(bb-pr-get-url <<<"$pr")" | tee /dev/stderr | xcopy } 2>&1
   echo
}

bb-pr-open() {
    local url=$(bb-pr-url)
    [ -n "$url" ] && xdg-open "${url}/builds"
}

bb-pr-cleanup() { # <pr-id>
    local pr_id="$1"
    local url="https://$(bb-current-domain)/rest/pull-request-cleanup/latest/projects/$(bb-current-project)/repos/$(bb-current-repo)/pull-requests/${pr_id}"
    jo -- deleteSourceRef=true retargetDependents=true \
        | bb-post-raw "$url" | jq
}

bb-pr-buildsummary() {
    bb-get-raw "$(bb-url-ui_latest)/pull-requests/$(bb-pr-id)/build-summaries"
}

bb-pr-check() {
    bb-get pull-requests/$(bb-pr-id)/merge | jq
}

bb-pr-merge() {
    local title
    local body
    local branch
    local pr_id
    local pr_json
    local pr_version
    local pr_message
    local url
    local response

    pr_json=$(bb-pr-current)
    pr_id=$(jq .id <<<"$pr_json")
    pr_version=$(jq .version <<<"$pr_json")

    title="$(git-get-title) (#${pr_id})"
    body=$(git-get-body)

    {
        echo "${fg_bold[default]}Will merge PR:${reset_color} $title"
        echo
        echo "${fg_bold[default]}Body:${reset_color}"
        echo "$body"
    } >&2
    gum confirm "Merge Pull Request?" || return 0

    pr_message=$(printf "%s\n\n%s" "$title" "$body")
    url="pull-requests/$(bb-pr-id)/merge?markup=true&version=${pr_version}"

    response=$(jo -- autoSubject=false message="$pr_message" | bb-post_latest "$url")

    jq<<<"$response"

    if jq -e ".errors" <<<"${response}">/dev/null; then
        jq <<<"$response"
        return 1
    fi

    bb-pr-cleanup "${pr_id}"
}

bb-pr-create() {
    local title
    local body
    local branch
    title=$(git-get-title)
    body=$(git-get-body)
    branch=$(git rev-parse --symbolic-full-name HEAD)
    {
        echo "${fg_bold[default]}Will create PR:${reset_color} $title"
        echo
        echo "${fg_bold[default]}Body:${reset_color}"
        echo "$body"
    } >&2

    if command -v gum >/dev/null; then
        gum confirm "Create Pull Request?" || return 0
    else
        echo "Continue (Y/n)?"
        read answer
        if [[ "$answer" != Y ]]; then
            return 0
        fi
    fi

    git push origin

    jo -- \
        title="$title" -s description="$body" state=OPEN \
        fromRef=$(jo id="$branch" slug="$(bb-current-repo)" name= project=$(jo key=$(bb-current-project))) \
        toRef=$(jo id=refs/heads/main slug="$(bb-current-repo)" name= project=$(jo key=$(bb-current-project))) \
        | bb-post pull-requests | jq

    bb-pr-url
    echo
}

bb-prs-status() {
    for d  in $(git worktree list | awk '! ( $1 ~ /main$/ ) {print $1}'); do
        (
        cd "$d"
        printf '# %s [%s]: %s\n' "$(basename "$d")" "$(git rev-parse --abbrev-ref HEAD)" "$(git-get-title)"
        bb-pr-check
        )
    done
}
