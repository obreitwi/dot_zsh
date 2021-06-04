get_bpm() {
    sox "$1" -t raw -r 44100 -e float -c 1 - | bpm -x ${max_bpm:-190}
}
