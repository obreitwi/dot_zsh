#!/bin/bash

# Quick install script to setup all symlinks

# SRCFLD=$(dirname $(realpath $0))
SRCFLD=$(dirname "$(readlink -m "$0")")

symlink () {
ln -s -f -v "$@"
}

mkdir -p "${HOME}/.config" || true

! [ -L "$HOME/.zsh" ] && symlink "$SRCFLD" "$HOME/.zsh"
symlink "$SRCFLD/zshrc" "$HOME/.zshrc"
symlink "$SRCFLD/zprofile" "$HOME/.zprofile"
symlink "$SRCFLD/starship/starship.toml" "$HOME/.config"
symlink "$SRCFLD/p10k/p10k.zsh" "$HOME/.p10k.zsh"
symlink "$SRCFLD/plugins/forgit/bin/git-forgit" "$HOME/.local/bin"

