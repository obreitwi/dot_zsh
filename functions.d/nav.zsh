
cd-r() {
    local target
    local height
    height=$(cdr -l | wc -l)
    target=$(cdr -l | fzf --nth 2.. --height=$height | sed -e "s:^[0-9]\+\s\+::" | sed "s:^~:$HOME:")

    cd "${target/\\ / }"
}
