# Usage:
#    targrepl <pattern> <tarfile>
#
# Prints all files matching <pattern> in <tarfile>. Just like `grep -l` does
# for normal files.
targrepl() {
    local pattern="$1"
    local tarfile="$2"
    tar Pxf "${tarfile}" --to-command "awk '/${pattern}/ { print ENVIRON[\"TAR_FILENAME\"]; exit }'"
}
