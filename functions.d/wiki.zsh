
wiki_set_work() {
    ln -Tsfv ~/doc-fdc/wiki ~/wiki
}

wiki_set_private() {
    ln -Tsfv ~/Nextcloud/wiki ~/wiki
}

# neorg
_todos_ex_grep='^\s*\(\*\|-\) \(( )\|\[[ .oO]\]\)'
_todos_ex_sed='s/^\([^:]*\):\(\s*\)\(\*\|-\) \(([ x])\|\[[ .oO]\]\)/\1\2/'
_todos_diary_path="$HOME/mwiki/neorg/journal"

# Get all recent todos
# Options:
#   -d --days Number of days to check (default 7)
get-todos() {
    zparseopts -D -E -A args d: -days: -all
    local days="${args[-d]}"
    if [ -z "$days" ]; then
        days="${args[--days]}"
    fi
    if [ -z "$days" ]; then
        days=14
    fi
    local -a files_new
    local -a files_old
    local entry_date

    cutoff_date="$(($(date +%s) - 3600 * 24 * days))"

    for entry_file in "${(@f)$(find "${_todos_diary_path}" -mindepth 1 -maxdepth 1 -type f | sort)}"; do
        entry_date=${entry_file:t:r}

        if (( $(date -d "$entry_date" +%s) < cutoff_date )); then
            files_old+=("${entry_file}")
        else
            files_new+=("${entry_file}")
        fi
    done

    # local grepex="^\s*\\* \[[ .oO]\]"
    # local sedex="s/^\([^:]*\):\(\s*\)\\* \[[ .oO]\]/\1\2/"
    grep "${_todos_ex_grep}" "${(O)files_new[@]}" | sed -e "${_todos_ex_sed}"
    echo -n "\n# Older:\n\n"
    grep "${_todos_ex_grep}" "${(O)files_old[@]}" | sed -e "${_todos_ex_sed}"
}

todos-errorfile() {
    grep -rn "${_todos_ex_grep}" "${(@f)$(find "${_todos_diary_path}" -mindepth 1 -maxdepth 1 -type f | sort -r)}" \
        | sed -e 's/\(\*\|-\) \(( )\|\[ \]\) //g'
}

# Open todos in vim
todos() {
    nvim -q <(todos-errorfile) +copen
}
