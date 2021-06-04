get-modeline() {
    cvt $1 $2 $3 | grep Modeline | sed -e "s/Modeline\s//"
}

startx-wifi() {
    # start the xserver with a given wifi profile
    sudo netctl start "${1}" &; startx
}
