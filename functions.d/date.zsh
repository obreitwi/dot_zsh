date-from-unix() {
    xargs -I{} date -d '@{}'
}
