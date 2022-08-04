
bb-current-project() {
    git remote get-url origin | awk -v FS=/ '{ print $(NF-1)}'
}

bb-current-repo() {
    git remote get-url origin | awk -v FS=/ '{ print $NF }' | sed "s:\.git$::"
}

bb-current-domain() {
    git remote get-url origin | awk -v FS=/ '{ print $3 }' | sed "s:^git@::"
}

bb-current-url() {
    echo "https://$(bb-current-domain)/rest/api/1.0/projects/$(bb-current-project)/repos/$(bb-current-repo)"
}

bb-user() {
    jq -r .user ~/.config/bitbucket/config.json
}

bb-get() { # <endpoint>
    curl -s --show-error -H "authorization: Bearer $(cat ~/.config/bitbucket/cli.token)" "$(bb-current-url)/$1"
}

bb-delete() { # <endpoint>
    curl -s --show-error -X DELETE -H "authorization: Bearer $(cat ~/.config/bitbucket/cli.token)" "$(bb-current-url)/$1"
}

bb-post() { # <endpoint>
    curl -s --show-error --json @- -H "authorization: Bearer $(cat ~/.config/bitbucket/cli.token)" "$(bb-current-url)/$1"
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

bb-pr-url() {
    bb-pr-current | jq -r ".links.self[0].href"
}

bb-pr-url() {
    bb-pr-current | jq -r ".links.self[0].href"
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

  jo -- title="$title" -s description="$body" state=OPEN \
      fromRef=$(jo id="$branch" slug="$(bb-current-repo)" name= project=$(jo key=$(bb-current-project))) \
      toRef=$(jo id=refs/heads/main slug="$(bb-current-repo)" name= project=$(jo key=$(bb-current-project))) \
      | bb-post pull-requests | jq

  bb-pr-url
}
