# 

mol new "../../common/12A.psf"
#mol new "12A.psf"
#mol new "out/filtered/No.TIP3.pdb"
mol addfile "out/12A_out.dcd" waitfor all
#mol addfile "../eq_2.out/out.dcd" waitfor all


proc calc_hbond {} {
    set sel [atomselect top "protein"]
    set N [molinfo top get numframes] 
    set file_out [open "ana/hbondIntra.dat" "w"]

    set cutoff 3.5
    set angle  40

    for {set i 0} {$i < $N} {incr i} {
        $sel frame $i
        set hbonds [llength [lindex [measure hbonds $cutoff $angle $sel] 0]]
        puts $file_out "$i $hbonds"
    }

    close $file_out
}


proc calc_hbondW {} {
    set selP  [atomselect top "protein"]
    set selW [atomselect top "water"]

    
    set N [molinfo top get numframes] 
    set file_out [open "ana/hbondW.dat" "w"]

    set cutoff 3.5
    set angle  40

    for {set i 0} {$i < $N} {incr i} {
        $selP frame $i
	$selW frame $i
        set hbondsDA [llength [lindex [measure hbonds $cutoff $angle $selP $selW] 0]]
	set hbondsAD [llength [lindex [measure hbonds $cutoff $angle $selW $selP] 0]]
	set Total [expr $hbondsDA*1.000 + $hbondsAD*1.000]  
	puts $file_out "$i $hbondsDA $hbondsAD $Total"
    }

    close $file_out
}




proc calc_dipole {} {
    set sel [atomselect top "protein"]
    set N [molinfo top get numframes] 
    set file_out [open "ana/dipole.dat" "w"]
    for {set i 0} {$i < $N} {incr i} {
	$sel frame $i
	set dipole [measure dipole $sel]
	set angle  [ expr 57.295*acos ([lindex [vecnorm $dipole] 2 ])]
	set dipole [veclength $dipole]
	puts $file_out "$i $dipole $angle"
    }
    close $file_out
}



calc_hbond
calc_dipole
calc_hbondW
quit
