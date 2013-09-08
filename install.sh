
#!/bin/bash

# Quick install script to setup all symlinks

PREFIX=$HOME/usr
# SRCFLD=$(dirname $(realpath $0))
SRCFLD=$(dirname $(readlink -m "$0"))

symlink () {
ln -s -f -v $*
}

mkdir -p $PREFIX/bin $PREFIX/share/man

symlink $SRCFLD $HOME/.zsh
symlink $SRCFLD/zshrc $HOME/.zshrc

