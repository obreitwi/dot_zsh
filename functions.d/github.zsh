
gh-my-pr() {
    gh pr list -A "$USER"
}

gh-make-pr() {
    local num_commits
    # TODO: If needed, make these optional
    local upstream
    upstream="origin/main"
    num_commits=$(git rev-list --count ${upstream}..HEAD)
    gh pr create \
        -t "$(git log --skip $((num_commits-1)) -n 1 --pretty=format:%s)" \
        -b "$(git log --skip $((num_commits-1)) -n 1 --pretty=format:%b)" \
        "${@}" >&2
}

_gh-make-pr() {
  # read from carapace
  # To update:
  # * re-read via `carapace gh zsh`
  # * extract function body
  # * modify words to replace gh-make-pr
  local IFS=$'\n'
  words="${words/gh-make-pr/gh pr create}"
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
compdef _gh-make-pr gh-make-pr
