nix-updates() { # <num older generation>
   local to_compare=1
   if (( $# > 0 )); then
      to_compare=$1
      shift
   fi
   nvd diff $(home-manager generations | tail -n +$((1 + to_compare)) | head -n 1 | awk '{ print $NF }') $(home-manager generations |  head -n 1 | awk '{ print $NF }')
}

# nix list derivation contents
nls() { # <package>
   if (( $# != 1 )); then
      echo "# Usage: nls <package>"
      return
   fi
   local out_path
   out_path=$(nix build --no-link --print-out-paths "nixpkgs#$1")

   if (( $? > 0 )); then
      return $?
   fi
   lsd --tree "$out_path"
}

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
