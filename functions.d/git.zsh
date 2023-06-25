clang_format_head() {
    file_list=("${(@f)$(git diff-tree ${1:-HEAD} --no-commit-id --name-only -r \
        | grep "\.\(c\|cpp\|tcc\|h\|hpp\)$" \
        | xargs ls -d 2>/dev/null \
        )}")
    clang-format -i "${file_list[@]}"
    sed -i "s:^\(} // namespace .*\)GENPYBIND_TAG_.*$:\1:" "${file_list[@]}"
    git status
}

git-branch-jira-id() {
    git branch --show-current | cut -d / -f 2
}

alias -g git-with-ci-ids-local='-m "$(git-rev-from-jira $(git-branch-jira-id))"'
alias -g git-with-ci-ids='-m "$(rev-git-ids $(rev-backlog -j $(git-branch-jira-id)))"'

# nicer git log
gitlg() {
    PAGER=/usr/bin/less git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $@ --
}

_git
compdef __git_branch_names gitlg

zstyle ':completion:*:*:git:*' user-commands review:'gerrit code review'

(( $+functions[_git-review] )) ||
_git-review ()
{
    local -a changes

    _arguments "-d[checkout change]:change:->change" "-l[list changes]" "-x[cherrypick change]:change:->change"

    case "${state}" in
        change)
            changes=("${(@f)$(git review -l | grep -v "^Found" | awk '{ $1=sprintf("%d:", $1); $2=sprintf("[%s]", $2); print }')}")
            if [[ "${changes[1]}" == "0: [determine] where .git directory is." ]]; then
                _message "Could not determine where .git directory is."
            elif [[ "${changes[1]}" == "0: ['.gitreview'] file found in this repository. We don't know where" ]]; then
                _message "No .gitreview found."
            elif [[ "${changes[1]}" == 0* ]]; then
                _message "No changes found."
            else
                _describe "Change Set" changes
            fi
            ;;
    esac
}

# inspired by: https://compiledsuccessfully.dev/git-skip-worktree/

# checks for any files flagged w/ --skip-worktree alias
git-check-skipped() {
    git ls-files -v | grep '^S' | cut -d' ' -f2-
}

# print the first found Jira and Rev tags
git-get-ci-ids() {
    git log "$@" \
        | awk '$1 ~ /Jira:/ && jira_found == 0 { print; jira_found=1 } $1 ~ /Rev:/ && rev_found == 0 { print; rev_found=1 }' \
        | sed "s:^\s*::g"
}
compdef __git_branch_names git-get-ci-ids

git-rev-from-jira() {
    if (( $# == 0 )); then
        echo "Usage: git-rev-from-jira-id JIRA-ID [<branch>]" >&2
        return 1
    fi
    local rev_id_to_find
    rev_id_to_find="$1"
    shift
    git log "$@" \
        | awk -v "to_find=${rev_id_to_find}" '
            $1 == "commit" {
                if (rev_found && jira_found && jira_id == to_find) {
                    printf("Jira: %s\nRev: %s\n", jira_id, rev_id)
                    exit 0
                } else {
                    jira_found=0;
                    rev_found=0;
                    jira_id=""
                    rev_id=""
                }
            }
            tolower($1) ~ /^jira:/ {
                jira_id=$2
                jira_found=1
            }
            tolower($1) ~ /^rev:/ {
                rev_id=$2
                rev_found=1
            }' \
        | sed "s:^\s*::g"
}
compdef __git_branch_names git-rev-from-jira

# add --skip-worktree flag to file
git-skip() {
    git update-index --skip-worktree "$@"
    git status
}

# remove --skip-worktree flag from file
git-unskip() {
    git update-index --no-skip-worktree "$@"
    git status
}

# perform the following action with temporarily unskipped files
git-with-skipped() {
    local -a skipped_files
    local -a action
    action=( "${@}" )
    skipped_files=("${(@f)$(git-check-skipped)}")
    git_unskip "${skipped_files[@]}"
    "${action[@]}"
    git_skip "${skipped_files[@]}"
}

git-get-folder-branches() {
    local -a folders=( "${@}" )
    if (( ${#folder[@]} == 0 )); then
        folders=( "${(f@)$(find . -mindepth 1 -maxdepth 1 -type d)}" )
    fi
    for d in *(/); do (
        cd "$d"
        branch="$(git branch --show-current 2>&1)"
        if (( $? == 0 )); then
            echo "$d\t$branch"
        fi
    )
    done
}

# show current branches of all folders in the current directory
git-show-branches() {
    git-get-folder-branches | awk -F "	" -vOFS="	" '{ print $1 ":", $2 }' | column -t -s "	"
}

git-cd-branches() {
    local target
    target=$(git-get-folder-branches "$@" | fzf -d "	" --with-nth 2.. | cut -d "	" -f 1)
    cd "${target}"
}

# display features of forgit
git-show-forgit() {
cat <<EOF
* git add selector (ga)
* git log viewer (glo)
 * The log graph can be disabled by option FORGIT_LOG_GRAPH_ENABLE (see discuss in [issue #71](https://github.com/wfxr/forgit/issues/71)).*
* .gitignore generator (gi)
* git diff viewer (gd)
* git reset HEAD <file> selector (grh)
* git checkout <file> selector (gcf)
* git checkout <branch> selector (gcb)
* git checkout <commit> selector (gco)
* git stash viewer (gss)
* git clean selector (gclean)
* git cherry-pick selector (gcp)
* git rebase -i selector (grb)
* git commit --fixup && git rebase -i --autosquash selector (gfu)
EOF
}
alias git-help-forgit=git-show-forgit

git-get-title() {
    git-from-first --format "%s" "$@"
}

git-get-body() {
    git-from-first --format "%b" "$@"
}

# Returns info from the first commit after the current --upstream branch in the form of --format
git-from-first() {
    zparseopts -D -E -A args -upstream: -format:
    local format
    format=${args[--format]}
    if [ -z "$format" ]; then
        echo "--format required" >&2
        return 1
    fi
    local upstream
    upstream="${args[--upstream]:-"origin/main"}"
    num_commits=$(git rev-list --count "${upstream}..HEAD")
    git log --skip $((num_commits-1)) -n 1 "--pretty=format:$format"
}

git-checkout-pubspec() {
(
    cd "$(git rev-parse --show-toplevel)"
    git checkout $(git status --porcelain | grep "pubspec.lock$" | awk '{ print $NF }')
)
}

git-grebl() {
    git grep -n "$@" | while IFS=: read i j k; do git blame -f -L $j,$j $i; done
}

alias grebl=git-grebl

# Get a diff between the latest good and currently earliest bad commit
git-diff-bisect() {
    git diff $(git bisect log | grep -v "^#" | grep good | tail -n 1 | awk '{print $4}')..$(git bisect log | grep -v "^#" | grep bad | tail -n 1 | awk '{print $4}') "$@"
}

git-root() {
   git rev-parse --show-toplevel
}

# vim: ft=zsh
