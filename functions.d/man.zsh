eg () {
        (( $+1 )) || {
                cat >&2 <<END
Usage: $0 [<args>...] [<expr>]

  args: Arguments to pass to man.
  expr: Command line argument to search for.
        Defaults to jump to the "EXAMPLE" section.

Examples:

  $0 find
  $0 less -s
  $0 1 less -s
  $0 zshall HIST_IGNORE_SPACE
  $0 zshall fc
END
                return 1
        }
        local expr='^EXAMPLE'
        local -a args
        args=("$@")
        (( $+2 )) && {
                expr="^[[:blank:]]*${@[-1]}"
                args=("${@[1,-2]}")
        }
        PAGER="less -g -s '+/$expr'" man "${=args}"
}

# It's shameless stolen from <http://www.vim.org/tips/tip.php?tip_id=167>
#f5# Use \kbd{vim} as your manpage reader
vman() {
    emulate -L zsh
    man $* | col -b | view -c 'set ft=man nomod nolist' -
}
