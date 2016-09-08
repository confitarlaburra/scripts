# Make a psf file for non-periodic and periodic CNTalong the z axis.
# Use with: vmd -dispdev text -e CG_pol_psf.tcl
# by jag modified from
# jcomer2@uiuc.edu

# Parameters:
# Should angles and dihedrals be calculated in addition to bonds?
#delete intermediate files
# "bondDistance" is used to determine whether a bond exists between atoms of each residue!!!.
set bondDistance 3.0
# MArtini pol water parameters
set resnameW PWE
set massW 24 
set massWP 24
set massWM 24 
set chargeW  0.0
set chargeWP 0.46
set chargeWM -0.46
set typePrefixW POL
set typePrefixWP DUM
set typePrefixWM DUM 
set numBondsW 3
set numBondsWM 3
set numBondsWP 3
set pdbName  H2O_CG
set outname  H2O_CG
set segNameP WP
set NatRes 3
## MAIN ##
proc main {} {
    global resnameW segNameP bondDistance outname pdbName NatRes
    global typePrefixW typePrefixWP typePrefixWM
    global nameW nameWP nameWM 
    global massW massWP massWM 
    global chargeW chargeWP chargeWM 
    global numBondsW numBondsWM numBondsWP
       
    mol load pdb $pdbName.pdb

    set nAtoms [molinfo top get numatoms]
    
    # Get the number of  atoms.
    set waterBox [atomselect top all]
    set nAtoms [$waterBox num]
    $waterBox delete
	
    # Find the internal bonds.
    puts "Bonding internal atoms..."
    set bond [bondAtoms all $bondDistance]
    puts "Internal bonds: [expr [llength $bond]/4]"
    
    mol delete top
    
    puts "Counting bonds on each atom..."
    countBonds count $bond $nAtoms
    puts "Reorganizing bond lists..."
    set bond [reorganizeBonds $bond]
    puts "Removing redundancy..."
    set bond [removeRedundantBonds $bond]
    set totalBonds [llength $bond]
    puts "Number of bonds: $totalBonds"
	
    set angle {}
    puts "Determining the angles..."
    set angle [findAngles $bond]
    set angle [RemoveAngles $angle]
    set totalAngles [llength $angle]
    puts "Number of angles: $totalAngles"

    	
    puts "Writing psf file..."
    manifestPsf "$outname.psf" "$outname.pdb"  $nAtoms bond angle count
    puts "The file $outname.psf was written successfully."
}


#Functions declarations

# Find bonds between internal atoms and return them.


#find bonded atoms
proc bondAtoms {selText bondDistance} {
    set sel [atomselect top $selText]
    set pos [$sel get {x y z}]
    set index [$sel get index]
    set resids [$sel get resid]
    $sel delete
    set bondDistance2 [expr $bondDistance*$bondDistance]
    set bond {}
    foreach r $pos ind $index resid $resids {
	# Select neighboring atoms.
	foreach {x y z} $r { break }
	set nearText "($x-x)^2+($y-y)^2+($z-z)^2 < $bondDistance2"
	set near [atomselect top \
		      "resid $resid and $nearText and not index $ind"]
	set nearNum [$near num]
	set nearIndex [$near get index]
	$near delete
	# Add them to the bond list.
	foreach i $nearIndex {lappend bond $ind $i}
    }
    return $bond
}

# Count the number of bonds on each atom and return an array (zero-based).
# The result is placed in a variable name countVar.
# Warning! The bond list is assumed to be flat and redundant.
proc countBonds {countVar bond nAtoms} {
    upvar $countVar count
    set num {}
    for {set i 0} {$i < $nAtoms} {incr i} {
	set n [llength [lsearch -all $bond $i]]
	set n [expr $n/2]
	lappend num $i $n
    }
    array set count $num
}

# Put the bonds into sublists.
# Reindex to a 1-based index.
proc reorganizeBonds {bond} {
    set ret {}
    foreach {b0 b1} $bond {
	incr b0
	incr b1
	lappend ret [list $b0 $b1]
    }
    return $ret
}

# We should now have all of the bonds twice.
# Find the unique bonds.
proc removeRedundantBonds {bond} {
    set ret {}
    foreach b $bond {
	set bPerm [list [lindex $b 1] [lindex $b 0]]
	set match [lsearch $ret $bPerm]
	# Add the bond to "ret" only if it is unique.
	if {$match == -1} {lappend ret $b}
    }
    return $ret
}

# Find the angles.
proc findAngles {bond} {
    set totalBonds [llength $bond]
    set totalBonds1 [expr $totalBonds - 1]
    # Find bonds that share atoms.
    set angle {}
    for {set i 0} {$i < $totalBonds1} {incr i} {
	for {set j [expr $i+1]} {$j < $totalBonds} {incr j} {
	    foreach {a0 a1} [lindex $bond $i] {break}
	    foreach {b0 b1} [lindex $bond $j] {break}
	    if {$a0 == $b0} {
		lappend angle [list $a1 $a0 $b1]
	    } elseif {$a0 == $b1} {
		lappend angle [list $a1 $a0 $b0]
	    } elseif {$a1 == $b0} {
		lappend angle [list $a0 $a1 $b1]
	    } elseif {$a1 == $b1} {
		lappend angle [list $a0 $a1 $b0]
	    }
	}
    }
    return $angle
}
#Remove all angles in which oxgigen is not center (specific for )
proc RemoveAngles {angle} {
    set ret {}
    foreach a $angle {
	if { [expr [lindex $a 1] -1] % 3 == 0} {
	    lappend ret $a
	}
    }
    return $ret
}

# Write the psf file.
proc manifestPsf {psfFile pdbFile nAtoms bondVar angleVar countVar} {

    global typePrefixW typePrefixWP typePrefixWM
    global massW massWP massWM     
    global chargeW chargeWP chargeWM
    global numBondsW numBondsWM numBondsWP
    global resnameW segNameP NatRes
    # Import the big pass-by-reference stuff.
    upvar $bondVar bond
    upvar $angleVar angle
    upvar $countVar count
    
    set dummy "          0"
    set totalBonds [llength $bond]
    set totalAngles [llength $angle]
    set out [open $psfFile w]
	
    ##### HEADER
    puts $out "PSF"
    puts $out ""
    puts $out "       1 !NTITLE"
    puts $out " REMARKS original generated structure x-plor psf file"

    ##### ATOMS
    puts "Writing atom records..."
    puts $out ""
    puts $out "[format %8i $nAtoms] !NATOM"
    
    # Open the pdb to extract the atom records.
    set inStream [open $pdbFile r]
    set atom 1
    set segNum 1
    set Count 0
    foreach line [split [read $inStream] \n] {
	set string0 [string range $line 0 3]
	if {![string match $string0 "ATOM"]} {continue}
	
	# Extract each pdb field.
	set record [string range $line 0 5]
	set serial [string range $line 6 10]
	set name [string range $line 12 15]
	set altLoc [string range $line 16 16]
	set resName [string range $line 17 19]
	set chainId [string range $line 21 21]
	set resId [string range $line 22 25]
	set iCode [string range $line 26 26]
	set x [string range $line 30 37]
	set y [string range $line 38 45]
	set z [string range $line 46 53]
	set occupancy [string range $line 54 59]
	set beta [string range $line 60 65]
	set segName "$segNameP$segNum"
	if {$resId == 9999} { 
	    incr Count
	    puts $Count
	}
	if {$Count == $NatRes} {
	    incr segNum
	    puts "$Count $segNum"
	    set Count 0
	}
	set element [string range $line 76 77]
	set charge [string range $line 78 79]
	
	# Determine the type names.
	set numBonds $count([expr $atom-1])
	set typeC {}
	set chargeC {}
	set massC {}
	if {[string compare $name " W"]==1} {
	    set typeC ${typePrefixW}
	    set chargeC ${chargeW}
	    set massC ${massW}
	}
	if {[string compare $name " WM"]==1} {
	    set typeC ${typePrefixWM}
	    set chargeC ${chargeWM}
	    set massC ${massWM}
	}
	if {[string compare $name " WP"]==1} {
	    set typeC ${typePrefixWP}
	    set chargeC ${chargeWP}
	    set massC ${massWP}
	}
	# Write the atom record.	
	puts -nonewline $out [format "%8i " $atom]
	puts -nonewline $out [format "%-4s " $segName]
	set segName {}
	puts -nonewline $out [format "%-4i " $resId]
	if {$atom < 100} {
	    puts -nonewline $out [format "%-3s " $resName]
	    puts -nonewline $out [format "%-4s  " $name]
	    
	}
	if {$atom >= 100} {
	    puts -nonewline $out [format "%-4s " $resName]
	    puts -nonewline $out [format "%-3s " $name]
	    
	}
	if {$atom < 100} {
	    puts -nonewline $out [format "%-4s  " $typeC]
	}
	if {$atom >= 100} {
	    puts -nonewline $out [format "%-4s  " $typeC]
	}
	puts -nonewline $out [format "% 5.6f       " $chargeC]
	puts -nonewline $out [format "%6.4f " $massC]
	puts $out $dummy
	incr atom
    }
    close $inStream
    puts $out ""
    
    ##### BONDS
    # Write the bonds.
    set total [format %8i $totalBonds]
    puts $out "$total !NBOND: bonds"
    set num 0
    set counter 0
    # due to bug (I guess!!) in NAMD for MARTINI pol water WP-WM bond has to be the first bond in psf
    # for each residue, thus we swap bonds 
    foreach b $bond {
	incr counter
	if {$counter == 1} {
	    puts -nonewline $out [format "%8i%8i" [expr [lindex $b 0] +1] [expr [lindex $b 1] + 1] ]
	}
	if {$counter == 2} {
	    puts -nonewline $out [format "%8i%8i" [lindex $b 0] [expr [lindex $b 1]-1 ] ]
	}
	if {$counter == 3} {
	    puts -nonewline $out [format "%8i%8i" [expr [lindex $b 0]-1] [lindex $b 1] ]
	    set counter 0
	}
	incr num
	if {$num == 4} {
	    puts $out ""
	    set num 0
	}
    }
    puts $out ""

    ##### ANGLES
    # Write the angles.
    puts $out "[format %8i $totalAngles] !NTHETA: angles"
    set num 0
    foreach a $angle {
	puts -nonewline $out \
	    [format "%8i%8i%8i" [lindex $a 0] [lindex $a 1] [lindex $a 2]]
	incr num
	if {$num == 3} {
	    puts $out ""
	    set num 0
	}
    }
    puts $out ""
    ##### DIHEDRALS
    set nDihed 0
    puts $out ""
    puts $out "[format %8i $nDihed] !NPHI: dihedrals"
    puts $out ""
    # Write everything else.
    ##### IMPROPERS
    set nImpropers 0
    puts $out ""
    puts $out "[format %8i $nImpropers] !NIMPHI: impropers"
    puts $out ""
    
    ##### DONORS
    set nDonors 0
    puts $out ""
    puts $out "[format %8i $nDonors] !NDON: donors"
    puts $out ""
    
    ##### ACCEPTORS
    set nAcceptors 0
    puts $out ""
    puts $out "[format %8i $nAcceptors] !NACC: acceptors"
    puts $out ""
    
    ##### NON-BONDED
    set nNB 0
    puts $out ""
    puts $out "[format %8i $nNB] !NNB"
    puts $out ""
    
    set tmp [expr int($nAtoms/8)]
    set tmp2 [expr $nAtoms -$tmp*8]
    for {set i 0} {$i <$tmp} {incr i} {
	puts $out "       0       0       0       0       0       0       0       0"
    }
    set lastString ""
    for {set i 0} {$i <$tmp2} {incr i} {
	set lastString "${lastString}       0"
    }
    puts $out $lastString
    
    ####### GROUPS
    puts $out ""
    puts $out "       1       0 !NGRP"
    puts $out "       0       0       0"
    puts $out ""
    puts $out ""
    close $out
}




## run main procedure
main
exit
