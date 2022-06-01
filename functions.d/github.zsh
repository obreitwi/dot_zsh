
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
