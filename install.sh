
#!/bin/bash

# SRCFLD=$(dirname $(realpath $0))
SRCFLD=$(dirname $(readlink -m "$0"))

symlink () {
ln -s -f -v $*
}

symlink $SRCFLD $HOME/.zsh
symlink $SRCFLD/zshrc $HOME/.zshrc

