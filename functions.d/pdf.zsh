pdf_to_first() {
    local target
    target="${1}"
    # append .pdf extension if missing
    if [ ! -f "${target}" ] && [ -f "${target}.pdf" ]; then
        target="${target}.pdf"
    fi
    target_bak="${TMPDIR:-/tmp}/${target//\//%}.bak"
    cp -v "${target}" "${target_bak}"
    echo "Shrinking '${target}' to first page.." >&2
    pdfseparate -f 1 -l 1 "${target_bak}" "${target}"
}
