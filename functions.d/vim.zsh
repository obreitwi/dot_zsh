alias nv="neovide"

vg() {
    nvim -q <(grep -rn "$@")
}
