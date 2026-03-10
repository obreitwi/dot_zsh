
search_nixpkgs() { 
    xdg-open "https://github.com/search?q=$(urlencode <<< repo:NixOS/nixpkgs "$@")"
}
alias sn=search_nixpkgs
