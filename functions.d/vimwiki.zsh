
vimwiki_set_work() {
    ln -Tsfv ~/doc-fdc/vimwiki ~/.vimwiki
}

vimwiki_set_private() {
    ln -Tsfv ~/Nextcloud/vimwiki ~/.vimwiki
}

# Get all recent todos
# Options:
#   -d --days Number of days to check (default 7)
get_todos() {
    zparseopts -D -E -A args d: -days:
    local days="${args[-d]}"
    if [ -z "$days" ]; then
        days="${args[--days]}"
    fi
    if [ -z "$days" ]; then
        days=14
    fi
    grep "^\s*\\* \[ \]" ~/.vimwiki/diary/*.md(m-$days) | sed -e "s/^\([^:]*\):\s*\\* \[ \]/\1/"
}

# Open todos in vim
todos() {
    get_todos "${@}" | nvim -R -
}

