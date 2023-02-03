#!/usr/bin/env zsh

header-bearer() {
    echo -n "authorization: Bearer $(cat /tmp/bearer | tr -d '\n')"
}

urlencode() {
    echo -n "$@" | jq -sRr @uri
}
