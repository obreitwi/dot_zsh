heic_to_jpg() {
    for origin in "$@"; do
        extension=${origin:e}
        if [[ "${extension:l}" != "heic" ]]; then
            echo "Wrong extension: ${origin}" >&2
        else
            target="${origin:r}.jpg"
            tifig -v -p -q 95 -i ${origin} -o ${target}
        fi
    done
}

svg_to_pdf() {
    for origin in "$@"; do
        extension=${origin:e}
        if [[ "$extension" != "svg" ]]; then
            echo "Wrong extension: ${origin}" >&2
        else
            target="${origin:r}.pdf"
            inkscape --export-filename="${target}" --export-dpi=600 --export-area-page  "${origin}"
        fi
    done
}

svg_to_png() {
    for origin in "$@"; do
        extension=${origin:e}
        if [[ "$extension" != "svg" ]]; then
            echo "Wrong extension: ${origin}" >&2
        else
            target="${origin:r}.png"
            inkscape --export-filename="${target}" --export-dpi=600 --export-area-page "${origin}"
        fi
    done
}

svg_to_pdf_rsvg() {
    for origin in "$@"; do
        extension=${origin:e}
        if [[ "$extension" != "svg" ]]; then
            echo "Wrong extension: ${origin}" >&2
        else
            target="${origin:r}.pdf"
            rsvg-convert -f pdf --output "${target}" --dpi-x 600 --dpi-y 600 "${origin}"
        fi
    done
}

svg_to_png_rsvg() {
    for origin in "$@"; do
        extension=${origin:e}
        if [[ "$extension" != "svg" ]]; then
            echo "Wrong extension: ${origin}" >&2
        else
            target="${origin:r}.png"
            rsvg-convert -f png --output "${target}" --dpi-x 600 --dpi-y 600 "${origin}"
        fi
    done
}

# see https://trac.ffmpeg.org/wiki/Encode/MP3
to_mp3() {
    for origin in "$@"; do
        ffmpeg -i "${origin}" -vn -acodec libmp3lame -ac 2 -aq ${AQ:-2} -ar 48000 "${origin:t:r}.mp3"
    done
}
