# generate a random string of length $1
randstr() {
    strlen="${1:-8}"
    tr -cd "[:alnum:]" </dev/urandom 2>/dev/null | head -c "${strlen}"
}
