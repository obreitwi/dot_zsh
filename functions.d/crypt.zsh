gen_ssha512() {
    local pw="$1"
    while [ -z "${pw}" ]; do
        echo -n "Password: "
        read -s pw_1
        echo ""
        echo -n "Password (repeat): "
        read -s pw_2
        echo ""
        if [[ "${pw_1}" = "${pw_2}" ]] && [[ "${pw_2}" = "${pw_2}" ]]; then
            pw="${pw_1}"
        fi
    done
    local salt=$(cat /dev/urandom | head -c 8)
    (
        echo -n "${pw}${salt}" | openssl dgst -sha512 -binary
        echo -n ${salt}
    ) | openssl enc -a -A | awk '{ print "{SSHA512}"$0 }'
}
