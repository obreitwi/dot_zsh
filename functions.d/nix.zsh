
# nix show derivation
nsd() { 
   nix derivation show "$@" | jq
}

nsh() { # <packages>
   nix-shell --run zsh -p "let pkgs = (import <nixpkgs-unstable> {}); in with pkgs; [ $* ]"
}
