
xrandr-add-presentation() {
    local offset_y=17
    local geometry
    geometry="$(xrandr --listmonitors | grep HDMI | awk '{print $3}' | sed "s:+0+0::")"
    # pixel width
    pw="$(echo $geometry | cut -d / -f 1)"
    # pixel height
    ph="$(echo $geometry | cut -d / -f 2 | cut -d x -f 2)"
    # real width
    rw="$(echo $geometry | cut -d / -f 2 | cut -d x -f 1)"
    # real height
    rh="$(echo $geometry | cut -d / -f 3)"

    xrandr --setmonitor presentation $((pw / 2))/${rw}x$((ph-offset_y))/$((rh * (ph-offset_y)/ph))+0+${offset_y} none
}
