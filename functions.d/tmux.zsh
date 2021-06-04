tmux-launch-and-configure() {
    tmux new-session -d -s "$1"
    tmux source "$HOME/.tmux/$1.conf"
    tmux attach -t $1
}
