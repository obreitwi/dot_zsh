
search_nixpkgs_url() {
    echo "https://github.com/search?q=$(echo repo:NixOS/nixpkgs "$@" | tr -d '\n' | urlencode)"
}

search_nixpkgs() { 
    xdg-open "$(search_nixpkgs_url "$@")"
}
alias sn=search_nixpkgs
