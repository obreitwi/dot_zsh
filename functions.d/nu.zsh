# helpers based on nushell

nujson() {
   nu --stdin -c 'from json'
}

nuyaml() {
   nu --stdin -c 'from yaml'
}
