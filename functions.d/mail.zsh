print_mail() {
    local f_ps
    local f_pdf
    f_ps=$(mktemp -p "$HOME"/.cache/mutt -t print_mail_XXXXXXXX)
    f_pdf=$(mktemp -p "$HOME"/.cache/mutt -t print_mail_XXXXXXXX.pdf)
    muttprint -P A4 -p TO_FILE:"${f_ps}"; ps2pdf ${f_ps} ${f_pdf}
    rdocv "${f_pdf}"
    rm "${f_ps}" "${f_pdf}"
}
