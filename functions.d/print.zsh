# print all arguments on new lines
printl() {
    for a in "$@"; do echo $a; done
}
zle -N printl

# print all arguments with pwd prepended
printp() {
    for a in "$@"; do echo $(pwd -P)/$a; done
}
zle -N printp

# print all arguments with custom prefix
printc() {
    for a in "${@:2}"; do echo $1/$a; done
}
zle -N printc
