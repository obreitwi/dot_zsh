# It's shameless stolen from <http://www.vim.org/tips/tip.php?tip_id=167>
#f5# Use \kbd{vim} as your manpage reader
vman() {
    emulate -L zsh
    man $* | col -b | view -c 'set ft=man nomod nolist' -
}
