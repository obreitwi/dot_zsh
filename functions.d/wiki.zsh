
wiki_set_work() {
    ln -Tsfv ~/doc-fdc/wiki ~/wiki
}

wiki_set_private() {
    ln -Tsfv ~/Nextcloud/wiki ~/wiki
}

# neorg
_todos_ex_grep='^\s*\(\*\|-\) \(( )\|\[[ .oO]\]\)'
_todos_ex_sed='s/^\([^:]*\):\(\s*\)\(\*\|-\) \(([ x])\|\[[ .oO]\]\)/\1\2/'
_todos_diary_path="$HOME/wiki/neorg/journal"

# Get all recent todos
# Options:
#   -d --days Number of days to check (default 7)
todos-get() {
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

    for entry_file in "${(@f)$(find "${_todos_diary_path}" -mindepth 1 -maxdepth 1 -type f -name "*.norg" -not -name index.norg | sort)}"; do
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
    error_grep_args=( "$@" )
    shift "$#"
    find "${_todos_diary_path}" -mindepth 1 -maxdepth 1 -type f | sort -r | xargs grep -n "${_todos_ex_grep}" \
        | if (( ${#error_grep_args[@]} > 0 )); then grep "${error_grep_args[@]}"; else cat; fi \
        | sed -e 's/\(\*\|-\) \(( )\|\[ \]\) //g' -e 's/ %#taskid[^%]*%//g'
}

# Open todos in vim
todos() {
    nvim -q <(todos-errorfile "${@}") +copen
}

# ensure journal entry for today
journal-day() { # <day=today>
    local day=today
    if (( $# > 0 )); then
        day=$1
        shift 1
    fi
    local file_journal=$_todos_diary_path/$(date --iso -d "$day").norg
    if ! [ -f "$file_journal" ]; then
        cp -v "$_todos_diary_path/../template_journal.norg" "$file_journal"
    fi
    neorg-task-sync sync "$_todos_diary_path"
}
