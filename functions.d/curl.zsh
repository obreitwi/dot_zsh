#!/usr/bin/env zsh

header-auth-bearer() {
    echo -n "authorization: Bearer $(cat /tmp/bearer | tr -d '\n')"
}
alias header-bearer=header-auth-bearer

header-auth-basic() {
    echo -n "authorization: $(cat /tmp/auth-basic | tr -d '\n')"
}

urlencode() {
    jq -sRr @uri
}
