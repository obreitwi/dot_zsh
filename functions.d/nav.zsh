
cd-r() {
    local target
    local height
    height=$(cdr -l | wc -l)
    target=$(cdr -l | fzf --nth 2.. --height=$height | awk '{ print $2 }' | sed "s:^~:$HOME:")

    cd "${target}"
}
