# print all arguments on new lines
printl() {
    for a in "$@"; do echo $a; done
}

# print all arguments with pwd prepended
printp() {
    for a in "$@"; do echo $(pwd -P)/$a; done
}

# print all arguments with custom prefix
printc() {
    for a in "${@:2}"; do echo $1/$a; done
}

print_mail() {
    local f_ps
    local f_pdf
    local mail_to_print
    if (( $# == 0 )); then
        echo "Need to specify mail!" >&2
        return 1
    fi
    mail_to_print="${1}"
    f_ps=$(mktemp -p "$HOME"/.cache/mutt -t print_mail_XXXXXXXX)
    f_pdf=$(mktemp -p "$HOME"/.cache/mutt -t print_mail_XXXXXXXX.pdf)
    muttprint -P A4 -p TO_FILE:"${f_ps}" < "${mail_to_print}"
    ps2pdf ${f_ps} ${f_pdf}
    rdocv "${f_pdf}"
    rm "${f_ps}" "${f_pdf}"
}
