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
