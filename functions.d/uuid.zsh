# parse binary uuid
parse-uuid() {
    base64 -d | xxd -p | sed -e 's:\(....\):\1-:g' | sed 's:-$::' | sed 's:\(^[^-]\)*-:\1:' | sed 's:-\([^-]*$\):\1:'
}
