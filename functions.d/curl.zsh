#!/usr/bin/env zsh

header-auth-bearer() {
    echo -n "authorization: Bearer $(cat /tmp/bearer | tr -d '\n')"
}
alias header-bearer=header-auth-bearer

urlencode() {
    jq -sRr @uri
}
