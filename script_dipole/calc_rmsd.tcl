#

mol new "/home/jgarate/dipole/BUILD/BUILD_12AM/input/12A_unsolvated.psf"
mol addfile "full.dcd" waitfor all

proc calc_rmsd {} {
    set ref [atomselect top "alpha" frame 0]
    set sel [atomselect top "alpha"]
    set all [atomselect top "all"]
    set N [molinfo top get numframes]
    set file_out [open "rmsd.dat" "w"]

    for {set i 0} {$i < $N} {incr i} {
        $sel frame $i
        $all frame $i

        set trans_mat [measure fit $sel $ref]
        $all move $trans_mat

        set rmsd [measure rmsd $sel $ref]
        puts $file_out "$i $rmsd"
    }

    close $file_out
}

calc_rmsd
quit
