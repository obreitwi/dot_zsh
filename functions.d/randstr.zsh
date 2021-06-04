# generate a random string of length $1
randstr() {
    if [[ $# > 0 ]]; then
        strlen="$1"
    else
        strlen="8"
    fi
    cat /dev/urandom 2>/dev/null | tr -cd "[:alnum:]" 2>/dev/null | head -c ${strlen}
}
