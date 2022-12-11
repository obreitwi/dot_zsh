
jwt-decode() {
    cut -d '.' -f 2 | base64 --decode 2>/dev/null | jq
}
