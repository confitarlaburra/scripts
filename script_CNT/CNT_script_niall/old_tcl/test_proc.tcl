# Finds the dihedrals based on a bond list
# checks for a common bond among bond triplets
# each element of bond contains 2 atoms indexes of unique bonds
# A-x = a0 a1
#   |
#   x-y = b0 b1
#     |
#     y-B = c0 c1
# torsion = a0-a1-b1-c1 or a0-b0-b1-c1 etc..... 
# There are 2**3 possible combinations
# But due to the symetry, (A-B-C-D)= (D-C-B-A)
# only four are needed  
#
proc findDihedrals {bond } {
    set totalBonds [llength $bond]
    # Find bonds that share atoms.
    set dihedral {}
    #loop through triplets (consider all pair due to cyclic molecules)
    for {set i 0} {$i < $totalBonds} {incr i} {
	foreach {a0 a1} [lindex $bond $i] {break}
	for {set j 0} {$j < $totalBonds} {incr j} {
	    foreach {b0 b1} [lindex $bond $j] {break}
	    set bool 1
	    #checks that the smae bonds are not compared
	    if { $b0==$a0 && $b1==$a1 } {set bool 0}
	    if {$bool == 1} {
		for {set k 0} {$k < $totalBonds} {incr k} {
		    foreach {c0 c1} [lindex $bond $k] {break}
		    set bool 1
		    #checks that the smae bonds are not compared
		    if { $c0==$b0 && $c1==$b1 } {set bool 0}
		    if {$bool == 1} {
			#case 1
			if {$a1 == $b0 && $b1 == $c0} {
			    lappend dihedral [list $a0 $a1 $b1 $c1]
			}
			#case 2
			if {$a1 == $b0 && $b1 == $c1} {
			    lappend dihedral [list $a0 $a1 $b1 $c0]
			}
			#case 3
			if {$a1 == $b1 && $b0 == $c0} {
			    lappend dihedral [list $a0 $a1 $b0 $c1]
			}

			#case 4
			#if {$a1 == $b1 && $b0 == $c1} {
			#    lappend dihedral [list $a0 $a1 $b0 $c0]
			#}
			
			#case 5			 
			if {$a0 == $b0 && $b1 == $c0} {
			    lappend dihedral [list $a1 $a0 $b1 $c1]
			}
						
			#case 6 symetric with 6
			#if {$a0 == $b0 && $b1 == $c1} {
			#    lappend dihedral [list $a1 $a0 $b1 $c0]
			#}

			#case 7 
			#if {$a0 == $b1 && $b0 == $c0} {
			#    lappend dihedral [list $a1 $a0 $b0 $c1]
			#}
			#case 8 
			#if {$a0 == $b1 && $b0 == $c1} {
			#    lappend dihedral [list $a1 $a0 $b0 $c0]
			#}

		    }
		}
	    }
	}
    }
    return $dihedral
}