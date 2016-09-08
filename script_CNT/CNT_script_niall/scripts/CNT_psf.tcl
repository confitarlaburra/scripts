# Make a psf file for non-periodic and periodic CNTalong the z axis.
# Use with: vmd -dispdev text -e CNT_psf.tcl
# by jag modified from
# jcomer2@uiuc.edu

# Parameters:
# Should angles and dihedrals be calculated in addition to bonds?
set findAngles 1
set findDihedrals  1
set zPeriodic 0
#delete intermediate files
set delete 1
#Period in z 
set lz 24 ; #trick to create a box or a fixed non-periodic tube in z
set period_z 24 ; #if lz and period z are different run  it with a fixed tube in z
set fixed 0 
# "bondDistance" is used to determine whether a bond exists between atoms.
set bondDistance 1.5
# CNT parameters
set resnameC CNT
set massC 12
set chargeC 0.0
set typePrefixC CA
set numBondsC 3
 #set tube chiral indexes
set n 6
set m 6
set length [format "%.1f" [expr $lz*0.1]] ; #in nm
set radius 3.8
set cutoff 12
set tresh 2.4
#output 
set selection1  "water and same residue as (within 2.8 of resname $resnameC)"
set selection2  "water and same residue as ( (x**2 + y**2) <= $radius**2 and z > -$lz*0.5 and z < $lz*0.5)"
set outname_raw "$n.$m.$length.raw"
set outname_final "$n.$m.$length"
set surfPdb surface.pdb
if {$zPeriodic} {
    set outname_final "$n.$m.$length.periodic.$lz"
}



## MAIN ##
proc main {} {
    global outname_final outname_raw surfPdb resnameC
    global findAngles findDihedrals zPeriodic
    global n m length lz delete period_z fixed
    global bondDistance radius cutoff selection1 selection2
    global nameC massC chargeC typePrefixC numBondsC
        
    package require psfgen
    package require solvate
       
    #build CNT
    build_CNT $n $m $length
    #rename CNT
    rename_CNT $resnameC $outname_final all
    #build non-periodic topology
    if {$zPeriodic} {
	build_topo_CNT all $typePrefixC $massC $chargeC 
    } else {
	build_topo_CNT all $typePrefixC $massC $chargeC 
    }

    

    set nAtoms [molinfo top get numatoms]
    
    # Get the number of carbon atoms.
    set carbon [atomselect top all]
    set numcarbon [$carbon num]
    $carbon delete
	
	
    # Find the internal bonds.
    puts "Bonding internal atoms..."
    set bond [bondAtoms all $bondDistance]
    puts "Internal bonds: [expr [llength $bond]/4]"
    
    # Bond to periodic images.	
    if {$zPeriodic} {
	# Create the surface atom pdb.
	set all [atomselect top all]
	$all set beta 1.0
	puts "Searching for surface atoms..."
	set nSurfC [markSurface $bond all $numBondsC]
	puts "Number of surface Carbons: $nSurfC"
	$all writepdb $surfPdb
	$all delete
	
	# Load it up.
	mol delete top
	mol load pdb $surfPdb
	
	puts "The system is periodic along the z-axis."
	puts "Period in z: period in z"
	set zCen [list [list 0 0 -${period_z}] [list 0 0 $period_z]]
	
	# Find the bonds on the periodic boundaries.
	puts "Bonding to the periodic image..."
	foreach r $zCen {
	    set bond [concat $bond \
			  [bondPeriodic all $bondDistance $r]]
	}
	if {$delete} {
	    file delete $surfPdb
	}
    }
	

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
    if {$findAngles} {
	puts "Determining the angles..."
	set angle [findAngles $bond]
	set totalAngles [llength $angle]
	puts "Number of angles: $totalAngles"
	}

    set dihedral {}
	if {$findDihedrals} {
		puts "Determining the dihedrals angles..."
		set dihedral [findDihedrals $bond]
		set totalDihedrals [llength $dihedral]
		puts "Number of dihedral angles: $totalDihedrals"
	}

	
    puts "Writing psf file..."
    manifestPsf "$outname_final.psf" "$outname_final.pdb"  $nAtoms bond angle dihedral count
    puts "The file $outname_final.psf was written successfully."
    mol delete all 
    mol load psf $outname_final.psf pdb $outname_final.pdb
    #center molecules
    puts "building solvation box..."
    set all [atomselect top all]

    $all moveby [vecinvert [measure center $all]]
    $all writepdb $outname_final.pdb
    $all delete

    
    if {$zPeriodic}  {
	set min_z  [expr  -$lz*0.5]
	set max_z  [expr $lz*0.5]
	if {$fixed} {
	    set min_z  [expr  -$lz*0.5 - $cutoff]
	    set max_z  [expr   $lz*0.5 + $cutoff]
	}
	    set min_x  [expr -$cutoff - $radius]
	    set max_x  [expr $cutoff + $radius]
	    set min_y  [expr -$cutoff - $radius]
	    set max_y  [expr $cutoff + $radius]
    }
    if {!$zPeriodic } {
	set min_z  [expr  -$lz*0.5 - $cutoff]
    	set max_z  [expr   $lz*0.5 + $cutoff]
	set min_x  $min_z
	set max_x  $max_z
        set min_y  $min_z
	set max_y  $max_z

    }
    
    solvate -o box -minmax "{$min_x $min_y $min_z} {$max_x $max_y $max_z}"

    mol delete all
    resetpsf
    readpsf  $outname_final.psf
    coordpdb $outname_final.pdb
    readpsf box.psf
    coordpdb box.pdb
    writepsf $outname_final.box.RAW.psf
    writepdb $outname_final.box.RAW.pdb
    resetpsf

    if {$delete} {
	file delete box.pdb
	file delete box.psf
	file delete box.log
    }

    #Delete unwanted atoms
    puts "Deleting overlaping atoms"
    mol load psf $outname_final.box.RAW.psf pdb $outname_final.box.RAW.pdb
    set bad [atomselect top "$selection1"]
    set seglist [$bad get segid]
    set reslist [$bad get resid]
    set bad [atomselect top "$selection2"]
    set seglist [concat $seglist \
		     [$bad get segid]]
    set reslist [concat $reslist \
		     [$bad get resid]]
    mol delete all
    
    resetpsf
    readpsf  $outname_final.box.RAW.psf
    coordpdb $outname_final.box.RAW.pdb
    foreach segid $seglist resid $reslist {
	delatom $segid $resid
    }
    writepsf $outname_final.box.psf
    writepdb $outname_final.box.pdb
    if {$delete} {
	file delete $outname_final.box.RAW.psf
	file delete $outname_final.box.RAW.pdb
    }
    mol load psf $outname_final.box.psf pdb $outname_final.box.pdb
    set CNT [atomselect top "resname $resnameC"]
    set all [atomselect top  all]
    $all set beta 0
    $CNT set beta 1
    $all writepdb $outname_final.box.fix
    set box [box_size "all" 0]
    set out [open min_max.txt w]
    puts $out "min max (x,y,z) and total is :$box"
    close $out
}


#Functions declarations

# Find bonds between internal atoms and return them.

#Write a single walled CNT with n,m chiral indexes and length (in nm) 

proc build_CNT { n m length } {
    package require nanotube
    nanotube -l $length -n $n -m $m
    set all [atomselect top all]
    $all writepdb "$n.$m.raw.pdb"
}

#Rename CNT as a single residue (resname)

proc rename_CNT {resname  outname sel} {
    set sel [atomselect top "$sel"]
    set i 1
    foreach index [$sel get index] {
	set single [atomselect top "index $index"]
	$single set resname $resname
	$single set segname $resname
	$single set resid 1
	$single set name C$i
	incr i
	$single delete
    } 
    $sel writepdb "$outname.pdb"
}

#Build non-periodic topology

proc build_topo_CNT {sel type mass charge} {
    package require topotools
    set sel [atomselect top "$sel"]
    $sel set type CA
    $sel set mass $mass
    $sel set charge $charge
    mol bondsrecalc top
    topo retypebonds
    topo guessangles
    topo guessdihedrals
    mol reanalyze top
}


#find bonded atoms
proc bondAtoms {selText bondDistance} {
	set sel [atomselect top $selText]
	set pos [$sel get {x y z}]
	set index [$sel get index]
	$sel delete

	set bondDistance2 [expr $bondDistance*$bondDistance]
	set bond {}
	foreach r $pos ind $index {
		# Select neighboring atoms.
		foreach {x y z} $r { break }
		set nearText "($x-x)^2+($y-y)^2+($z-z)^2 < $bondDistance2"
		set near [atomselect top \
		"$selText and $nearText and not index $ind"]
		set nearNum [$near num]
		set nearIndex [$near get index]
		$near delete
	
		# Add them to the bond list.
		foreach i $nearIndex {lappend bond $ind $i}
	}
	return $bond
}



# Try to bond surface atoms to the periodic image.
proc bondPeriodic {selText bondDistance periodicDisp} {
	set selText "$selText and beta == 0.0"
	set sel [atomselect top $selText]
	set pos [$sel get {x y z}]
	set index [$sel get index]
		
	# Shift all of the atoms into this periodic image.
	$sel moveby $periodicDisp
		
	set bondDistance2 [expr $bondDistance*$bondDistance]
	set bond {}
	foreach r $pos ind $index {
		# Select neighboring atoms.
		foreach {x y z} $r { break }
		set nearText "($x-x)^2+($y-y)^2+($z-z)^2 < $bondDistance2"
		set near [atomselect top \
		"$selText and $nearText and not index $ind"]
		set nearNum [$near num]
		set nearIndex [$near get index]
		$near delete
	
		# Add them to the bond list.
		foreach i $nearIndex {lappend bond $ind $i}
	}

	# Return all atoms to their original position.
	$sel set {x y z} $pos
	$sel delete
		
	return $bond
}


# Find the atoms that have fewer than "numBonds" bonds.
# Mark surface atoms by beta = 0.0.
# Warning! The bond list is assumed to be flat and redundant.
proc markSurface {bond selText numBonds} {
	set sel [atomselect top $selText]
	set index [$sel get index]
	set nSurfAtoms 0
	
	foreach i $index {
		# Find the number of bonds for each atom.
		set n [llength [lsearch -all $bond $i]]
		# Assume each bond is in the list twice.
		set n [expr $n/2]
		
		# Set the beta value to 0.0 if the atom is on the surface.
		if {$n < $numBonds} {
			set s [atomselect top "index $i"]
			$s set beta 0.0
			incr nSurfAtoms
			$s delete	
		}
	}
	$sel delete
	
	return $nSurfAtoms
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



#JAG 17-04-14
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



# Write the psf file.
proc manifestPsf {psfFile pdbFile nAtoms bondVar angleVar dihedVar countVar} {
    global nameC massC chargeC typePrefixC numBondsC
    # Import the big pass-by-reference stuff.
    upvar $bondVar bond
    upvar $angleVar angle
    upvar $dihedVar dihedral
    upvar $countVar count
    
    set dummy "          0"
    set totalBonds [llength $bond]
    set totalAngles [llength $angle]
    set totalDihedral [llength $dihedral]
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
	set segName [string range $line 72 75]
	set element [string range $line 76 77]
	set charge [string range $line 78 79]
	
	# Determine the type names.
	set numBonds $count([expr $atom-1])
	set typeC ${typePrefixC}
	
	# Write the atom record.	
	puts -nonewline $out [format "%8i " $atom]
	puts -nonewline $out [format "%-4s " $segName]
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
    foreach b $bond {
	puts -nonewline $out [format "%8i%8i" [lindex $b 0] [lindex $b 1]]
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
    set num 0
    puts $out ""
    puts $out "[format %8i $totalDihedral] !NPHI: dihedrals"
    foreach a $dihedral {
	puts -nonewline $out \
	    [format "%8i%8i%8i%8i" [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3]]
	incr num
	if {$num == 2} {
	    puts $out ""
	    set num 0
	}
    }
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

#procedure to get min max + cutoff of solute
proc box_size { sel cutoff } {
     set minmax [measure minmax [atomselect top "$sel"]]
     set min_xyz [lindex $minmax 0]
     set max_xyz [lindex $minmax 1]
     
     set min_x [lindex $min_xyz 0]
     set max_x [lindex $max_xyz 0]

     set min_y [lindex $min_xyz 1]
     set max_y [lindex $max_xyz 1]  

     set min_y [lindex $min_xyz 1]
     set max_y [lindex $max_xyz 1]

     set min_z [lindex $min_xyz 2]
     set max_z [lindex $max_xyz 2]
    
     set x_box_size_min [expr $min_x - $cutoff]
     set x_box_size_max [expr $max_x + $cutoff]

     set y_box_size_min [expr $min_y - $cutoff]
     set y_box_size_max [expr $max_y + $cutoff]


     set z_box_size_min [expr $min_z - $cutoff]
     set z_box_size_max [expr $max_z + $cutoff]
      
     
     set box_x [expr abs($min_x)+ abs($max_x) + 2*$cutoff ] 
     set box_y [expr abs($min_y)+ abs($max_y) + 2*$cutoff ]
     set box_z [expr abs($min_z)+ abs($max_z) + 2*$cutoff ]
     
     set box_min_max " $x_box_size_min $y_box_size_min $z_box_size_min $x_box_size_max  $y_box_size_max  $z_box_size_max"
     set box " $box_x $box_y $box_z "
     return "$box_min_max $box"
}



## run main procedure
main
exit
