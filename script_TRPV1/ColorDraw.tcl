set CollDipPz 0.96
set Chain(A) {7.76 0.38}
set Chain(B) {7.72 0.42}
set Chain(C) {7.20 0.36}
set Chain(D) {7.33 0.06}
set chains {A B C D}
set firstRes 631
set lastRes 643
#Average Dipole Magnitudes by chain and residue
set Dip(A) {1.03 0.84 0.70 0.79 0.80 2.61 0.79 0.82 4.53 0.80 0.43 0.57 0.65}
set Dip(B) {1.12 0.84 0.86 0.80 0.80 2.60 0.79 0.80 4.55 0.77 0.67 0.55 0.71}
set Dip(C) {1.12 0.92 0.85 0.82 0.78 2.61 0.77 0.77 4.59 0.79 0.59 0.56 0.68}
set Dip(D) {1.07 0.81 0.49 0.77 0.78 2.60 0.76 0.81 4.58 0.78 0.56 0.59 0.66}
#Average P1z by chain and residue
set Pz(A) {0.67 0.38 -0.06 0.48 0.60 -0.65 0.20 0.38 0.93 0.31 0.29 0.16 -0.31}
set Pz(B) {0.55 0.26 -0.08 0.49 0.57 -0.77 0.16 0.44 0.93 0.29 0.65 0.11 -0.38}
set Pz(C) {0.48 0.17 -0.20 0.42 0.51 -0.76 0.16 0.41 0.93 0.25 0.40 0.11 -0.42}
set Pz(D) {0.38 0.22 -0.32 0.13 0.31 -0.79 -0.05 0.12 0.77 0.09 0.16 -0.04 -0.45}

#Procedures

proc ColorDip { &arrName} {
    global chains firstRes lastRes      
    upvar 1 ${&arrName} Dip
    set all [atomselect top all]
    $all set beta 0
    $all delete
    foreach chain $chains {
	set j 0
	for {set i $firstRes} {$i <=$lastRes} {incr i} {
	    set sel [atomselect top "chain $chain and resid $i"]
	    $sel set beta [lindex $Dip($chain) $j]
	    incr j
	    $sel delete
	}
    }
}


proc ColorChain { &arrName} {
    global chains firstRes lastRes      
    upvar 1 ${&arrName} Chain
    set all [atomselect top all]
    $all set beta 7.33
    $all delete
    foreach chain $chains {
	set sel [atomselect top "chain $chain and resid $firstRes to $lastRes"]
	$sel set beta [lindex $Chain($chain) 0]
	$sel delete
    }
}



proc DrawArrowsRes { chain &arrName } {
    global firstRes lastRes
    upvar 1 ${&arrName} Pz
    set j 0
    for {set i $firstRes} {$i <=$lastRes} {incr i} {
	set center [measure center  [atomselect top "chain $chain and resid $i and name CA"]]
	set z [lindex $Pz($chain) $j]
	set x [expr sqrt(1 -$z*$z)]
	set vector {}
	lappend vector $x
	lappend vector 0.0
	lappend vector $z
	graphics top color yellow
	graphics top cylinder $center [vecadd $center [vecscale 2 $vector]] radius 0.2 resolution 6 filled yes
	graphics top cone [vecadd $center [vecscale 2 $vector]] [vecadd $center [vecscale 2.7 $vector]] radius 0.34 resolution 6
	incr j
    }
}

proc DrawArrowsChain {&arrName } {
    global firstRes lastRes chains
    upvar 1 ${&arrName} Chain
    foreach chain $chains {
	set center [measure center  [atomselect top "chain $chain and resid $firstRes to $lastRes"]]
	set z [lindex $Chain($chain) 1]
	set x [expr sqrt(1 -$z*$z)]
	set vector {}
	lappend vector $x
	lappend vector 0.0
	lappend vector $z
	graphics top color green
	graphics top cylinder $center [vecadd $center [vecscale 10 $vector]] radius 0.2 resolution 6 filled yes
	graphics top cone [vecadd $center [vecscale 10 $vector]] [vecadd $center [vecscale 12 $vector]] radius 0.34 resolution 6
    }
}




proc DrawCollective { } {
    global firstRes lastRes
    global CollDipPz
    set center [measure center  [atomselect top "protein and resid $firstRes to $lastRes"]]
    set z $CollDipPz
    set x [expr sqrt(1 -$z*$z)]
    set vector {}
    lappend vector $x
    lappend vector 0.0
    lappend vector $z
    graphics top color yellow
    graphics top cylinder $center [vecadd $center [vecscale 15 $vector]] radius 0.2 resolution 6 filled yes
    graphics top cone [vecadd $center [vecscale 15 $vector]] [vecadd $center [vecscale 17 $vector]] radius 0.34 resolution 6
}

proc main {} {
    DrawCollective
    DrawArrowsChain Chain
    ColorDip Dip
    DrawArrowsRes A Pz

}
