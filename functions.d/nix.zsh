
# nix show derivation
nsd() { 
   nix derivation show "$@" | jq
}
