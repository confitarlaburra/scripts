#

mol new "../../common/12A.psf"
mol addfile "out/12A_out.dcd" waitfor all

proc calc_sasa {} {
    set sel [atomselect top "protein"]
    set N [molinfo top get numframes]
    set file_out [open "ana/sasa.dat" "w"]

    for {set i 0} {$i < $N} {incr i} {
        $sel frame $i
        set sasa [measure sasa 1.4 $sel]
        puts $file_out "$i $sasa"
    }
    close $file_out
}

calc_sasa
quit
