clang_format_head() {
    file_list=("${(@f)$(git diff-tree ${1:-HEAD} --no-commit-id --name-only -r \
        | grep "\.\(c\|cpp\|tcc\|h\|hpp\)$" \
        | xargs ls -d 2>/dev/null \
        )}")
    clang-format -i "${file_list[@]}"
    sed -i "s:^\(} // namespace .*\)GENPYBIND_TAG_.*$:\1:" "${file_list[@]}"
    git status
}

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

# vim: ft=zsh
