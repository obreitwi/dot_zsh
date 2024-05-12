
# nix show derivation
nsd() { 
   nix derivation show "$@" | jq
}

nsh() { # <packages> -- <other args to `nix shell`>
   local -a pkgs
   local end_of_packages=0
   while (( $# > 0  && end_of_packages == 0 )); do

      case $1 in
         --)
            end_of_packages=1
         ;;
         *)
            pkgs+=("$1")
         ;;
      esac
      shift 1
   done

   nix shell "${pkgs[@]/#/nixpkgs#}" "$@"
}
