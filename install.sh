#!/bin/bash

# Quick install script to setup all symlinks

# SRCFLD=$(dirname $(realpath $0))
SRCFLD=$(dirname $(readlink -m "$0"))

symlink () {
ln -s -f -v $*
}

symlink $SRCFLD $HOME/.zsh
symlink $SRCFLD/zshrc $HOME/.zshrc
symlink $SRCFLD/zprofile $HOME/.zprofile

