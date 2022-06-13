
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
    local diary_path="$HOME/.vimwiki/diary"
    zparseopts -D -E -A args d: -days:
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

    for entry_file in "${(@f)$(find "${diary_path}" -mindepth 1 -maxdepth 1 -type f | sort)}"; do
        entry_date=$(basename "${entry_file%%.md}")

        if (( $(date -d "$entry_date" +%s) < cutoff_date )); then
            files_old+=("${entry_file}")
        else
            files_new+=("${entry_file}")
        fi
    done

    local grepex="^\s*\\* \[[ .oO]\]"
    local sedex="s/^\([^:]*\):\(\s*\)\\* \[[ .oO]\]/\1\2/"
    grep "${grepex}" "${(O)files_new[@]}" | sed -e "${sedex}"
    echo -n "\n# Older:\n\n"
    grep "${grepex}" "${(O)files_old[@]}" | sed -e "${sedex}"
}

# Open todos in vim
todos() {
    tmpfile=$(mktemp)
    get_todos "${@}" >"${tmpfile}"
    nvim "${tmpfile}"
    rm -f "${tmpfile}"
}
