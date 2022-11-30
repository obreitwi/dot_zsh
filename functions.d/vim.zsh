alias nv="neovide --multigrid"

vg() {
    nvim -q <(grep -rn "$@")
}
