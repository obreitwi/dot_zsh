
# Checkout the first available dummy branch to indicate worktree is not used
gh-dummy() {
  local remove_branch=1
  local branch_old=$(git-branch)
  gh pr view --json state | jq --exit-status '.state | match("MERGED")' >/dev/null
  remove_branch=$?

  git-dummy
  if (( remove_branch == 0 )); then
    git branch -d "$branch_old"
  fi
}

gh-my-pr() {
    gh pr list -A "$USER"
}

gh-pr-create() {
  zparseopts -D -E -A args -upstream:
  local -a git_args
  if [ -n "${args[--upstream]}" ]; then
    git_args+=(--upstream "${args[--upstream]}")
  fi

  local title
  local body
  title="$(git-get-title "${git_args[@]}")"
  body="$(git-get-body "${git_args[@]}")"
  {
    echo "${fg_bold[default]}Will create PR:${reset_color} $title"
    echo
    echo "${fg_bold[default]}Body:${reset_color}"
    echo "$body"
    echo
  } >&2

  gh pr create -t "$title" -b "$body" "${@}" >&2
}

gh-pr-update() {
  zparseopts -D -E -A args -upstream:
  local -a git_args
  if [ -n "${args[--upstream]}" ]; then
    git_args+=(--upstream "${args[--upstream]}")
  fi

  local title
  local body
  title="$(git-get-title "${git_args[@]}")"
  body="$(git-get-body "${git_args[@]}")"
  {
    echo "${fg_bold[default]}Updating PR:${reset_color}"
    echo "$title"
    echo
    echo "$body"
    echo
  } >&2
  gum confirm "Proceed updating pull request?" || return 0

  gh pr edit -t "$title" -b "$body" "${@}" >&2
}

gh-pr-md() {
    local json
    json=$(gh pr view "$(git-branch)" --json title,url)
    { printf "[%s](%s)" "$(jq -r .title <<< "$json")" "$(jq -r .url <<< "$json")" | tee /dev/stderr | xcopy } 2>&1
    echo
}

gh-pr-md-fancy() {
    local json
    json=$(gh pr view "$(git-branch)" --json additions,deletions,number,title,url "$@")
    { printf "[#%s | %s | +%s,-%s](%s)" \
        "$(jq -r .number <<< "$json")" \
        "$(jq -r .title <<< "$json")" \
        "$(jq -r .additions <<< "$json")" \
        "$(jq -r .deletions <<< "$json")" \
        "$(jq -r .url <<< "$json")" \
        | tee /dev/stderr | xcopy } 2>&1
    echo
}
alias gpmf=gh-pr-md-fancy

gh-pr-md-fancy-emoji() {
    local json
    local icon
    local title

    json=$(gh pr view "$(git-branch)" --json additions,deletions,number,title,url "$@")
    title=$(jq -r .title <<< "$json")
    if grep -q '^feat'<<<"${title}"; then
      icon=":hammer_and_wrench: "
    elif grep -q '^chore'<<<"${title}"; then
      icon=":broom: "
    elif grep -q '^fix'<<<"${title}"; then
      icon=":adhesive_bandage: "
    elif grep -q '^doc'<<<"${title}"; then
      icon=":pencil: "
    elif grep -q '^refactor'<<<"${title}"; then
      icon=":building_construction: "
    fi
    { printf "%s[#%s | %s | +%s,-%s](%s)" \
        "${icon}" \
        "$(jq -r .number <<< "$json")" \
        "$(jq -r .title <<< "$json")" \
        "$(jq -r .additions <<< "$json")" \
        "$(jq -r .deletions <<< "$json")" \
        "$(jq -r .url <<< "$json")" \
        | tee /dev/stderr | xcopy } 2>&1
    echo
}
alias gpmfe=gh-pr-md-fancy-emoji

gh-pr-url-fancy-emoji() {
    local json
    local icon
    local title

    json=$(gh pr view "$(git-branch)" --json additions,deletions,number,title,url "$@")
    title=$(jq -r .title <<< "$json")
    if grep -q '^feat'<<<"${title}"; then
      icon="🛠️ "
    elif grep -q '^chore'<<<"${title}"; then
      icon="🧹"
    elif grep -q '^fix'<<<"${title}"; then
      icon="🩹"
    elif grep -q '^doc'<<<"${title}"; then
      icon="📝"
    elif grep -q '^refactor'<<<"${title}"; then
      icon="🏗"
    fi
    { printf "<html><head></head><body><a href=\"%s\">%s #%s | %s | +%s,-%s</a></body></html>" \
        "$(jq -r .url <<< "$json")" \
        "${icon}" \
        "$(jq -r .number <<< "$json")" \
        "$(jq -r .title <<< "$json")" \
        "$(jq -r .additions <<< "$json")" \
        "$(jq -r .deletions <<< "$json")" \
        | tee /dev/stderr | xcopy -t text/html } 2>&1
    echo
}
alias gpufe=gh-pr-url-fancy-emoji

gh-pr-merge() {
  zparseopts -D -E -A args -upstream:
  local -a git_args
  if [ -n "${args[--upstream]}"]; then
    git_args+=(--upstream "${args[--upstream]}")
  fi

  local title
  local body
  title="$(git-get-title "${git_args[@]}")"
  body="$(git-get-body "${git_args[@]}")"
  {
    echo "${fg_bold[default]}Will merge PR:${reset_color} $title"
    echo
    echo "${fg_bold[default]}Body:${reset_color}"
    echo "$body"
    echo
  } >&2

  gh pr merge -t "$title" -b "$body" "${@}" >&2
}

_gh-pr-create() {
  # read from carapace
  # To update:
  # * re-read via `carapace gh zsh`
  # * extract function body
  # * modify words to replace gh-make-pr
  local IFS=$'\n'
  words="${words/gh-pr-create/gh pr create}"
  # shellcheck disable=SC2207,SC2086,SC2154
  if echo ${words}"''" | xargs echo 2>/dev/null > /dev/null; then
    # shellcheck disable=SC2207,SC2086
    local c=($(echo ${words}"''" | xargs carapace gh zsh ))
  elif echo ${words} | sed "s/\$/'/" | xargs echo 2>/dev/null > /dev/null; then
    # shellcheck disable=SC2207,SC2086
    local c=($(echo ${words} | sed "s/\$/'/" | xargs carapace gh zsh))
  else
    # shellcheck disable=SC2207,SC2086
    local c=($(echo ${words} | sed 's/$/"/'  | xargs carapace gh zsh))
  fi

  # shellcheck disable=SC2034,2206
  local vals=(${c%%$'\t'*})
  # shellcheck disable=SC2034,2206
  local descriptions=(${c##*$'\t'})

  local suffix=' '
  [[ ${vals[1]} == *$'\001' ]] && suffix=''
  # shellcheck disable=SC2034,2206
  vals=(${vals%%$'\001'*})

  compadd -l -S "${suffix}" -d descriptions -a -- vals
}
compdef _gh-pr-create gh-pr-create

_gh-pr-merge() {
  # read from carapace
  # To update:
  # * re-read via `carapace gh zsh`
  # * extract function body
  # * modify words to replace gh-make-pr
  local IFS=$'\n'
  words="${words/gh-pr-merge/gh pr merge}"
  # shellcheck disable=SC2207,SC2086,SC2154
  if echo ${words}"''" | xargs echo 2>/dev/null > /dev/null; then
    # shellcheck disable=SC2207,SC2086
    local c=($(echo ${words}"''" | xargs carapace gh zsh ))
  elif echo ${words} | sed "s/\$/'/" | xargs echo 2>/dev/null > /dev/null; then
    # shellcheck disable=SC2207,SC2086
    local c=($(echo ${words} | sed "s/\$/'/" | xargs carapace gh zsh))
  else
    # shellcheck disable=SC2207,SC2086
    local c=($(echo ${words} | sed 's/$/"/'  | xargs carapace gh zsh))
  fi

  # shellcheck disable=SC2034,2206
  local vals=(${c%%$'\t'*})
  # shellcheck disable=SC2034,2206
  local descriptions=(${c##*$'\t'})

  local suffix=' '
  [[ ${vals[1]} == *$'\001' ]] && suffix=''
  # shellcheck disable=SC2034,2206
  vals=(${vals%%$'\001'*})

  compadd -l -S "${suffix}" -d descriptions -a -- vals
}
compdef _gh-pr-merge gh-pr-merge

gh-patch() {
  { gh pr view --json commits;  gh repo view --json url} | jq -sr ' add | .url + "/compare/" + .commits[0].oid + "%5E.." + .commits[-1].oid + ".patch"'
}
