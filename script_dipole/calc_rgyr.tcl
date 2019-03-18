#

mol new "../../common/12A.psf"
mol addfile "out/12A_out.dcd" waitfor all

proc calc_rgyr {} {
    set sel [atomselect top "protein"]
    set N [molinfo top get numframes]
    set file_out [open "ana/rgyr.dat" "w"]

    for {set i 0} {$i < $N} {incr i} {
        $sel frame $i
        set rgyr [measure rgyr $sel]
        puts $file_out "$i $rgyr"
    }
    close $file_out
}

calc_rgyr
quit
