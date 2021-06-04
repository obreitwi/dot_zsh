find_in_hist() {
    zgrep -i "$1" ~/.logs/*.gz
    grep -ri "$1" ~/.logs
}
alias fih=find_in_hist
