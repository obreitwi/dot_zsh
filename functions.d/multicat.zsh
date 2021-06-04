multicat() {
    for fname in $*; do
        for count in {0..$(( ${#fname} + 9 ))};do
            echo -n "#"
        done
        echo ""
        echo "# FILE: $fname #"
        for count in {0..$(( ${#fname} + 9 ))};do
            echo -n "#"
        done
        echo ""
        cat $fname
    done
}
