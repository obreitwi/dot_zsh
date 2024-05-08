az-pr-create() {
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
    local json
    json=$(az repos pr create --title "$title" --description "$body")
    echo "$(jq -r .repository.webUrl <<<"$json")/pullrequest/$(jq -r .codeReviewId <<<"$json")"
}

az-pr-current() { 
    az repos pr list | jq ".[] | select(.sourceRefName == \"$(git rev-parse --symbolic-full-name HEAD)\")"
}

az-pr-md() {
    local pr_json
    local repo_json
    local url
    pr_json=$(az-pr-current)
    repo_json=$(az-repo-current)
    pr_url=$(jq -r .webUrl <<<"$repo_json")/pullrequest/$(jq -r .codeReviewId <<<"$pr_json")
    title=$(jq -r .title <<<"$pr_json")
    echo "[$title]($pr_url)"
}

az-repo-current() {
    az repos show -r . | jq '.value[0]'
}

az-pr-url() {
    local pr_json
    local repo_json
    pr_json=$(az-pr-current)
    repo_json=$(az-repo-current)
    echo "$(jq -r .webUrl <<<"$repo_json")/pullrequest/$(jq -r .codeReviewId <<<"$pr_json")"
}
