uniq_lines() {
    cat -n $1 | sort -uk2 | sort -nk1 | cut -f2-
}

spack_modules() {
    TMPFILE="$(mktemp)"
    for mod in "$@"; do
        (echo "Loading $mod…" 1>&2)
        spack module loads -r $mod >> $TMPFILE
    done
    (echo "Committing…" 1>&2)
    uniq_lines $TMPFILE
    rm $TMPFILE
}

spack_load() {
    source =(spack_modules "$@")
}
