# nicer git log
gitlg() {
    PAGER=/usr/bin/less git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $@ --
}

_git
compdef __git_branch_names gitlg
