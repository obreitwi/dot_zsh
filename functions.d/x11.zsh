get-modeline() {
    cvt $1 $2 $3 | grep Modeline | sed -e "s/Modeline\s//"
}

startx-with-net() {

if (( # < 1 )); then
    echo "Usage: startx-with-net <profile>" >&2
    return 1
fi
local network="${1}"

if [ ! -f "/etc/netctl/$network" ]; then
    echo "Profile '${network}' does not exist." >&2
    return 1
fi

# start the xserver with a given wifi profile
sudo netctl start "${1}" &; startx
}

alias startx-wifi=startx-with-net
