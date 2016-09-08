#PBC center system based on solute #

set inPDB 1.pdb
set outPDB full.pdb
set center_selection "resname CCC"
set offset "1"
set box [ list 52.7 52.7 52.7]
set resname CCC
set segname 111
set outname "gathered.pdb"

# Writes a pdb file on an already open file.
proc writepdb_full {pdbFile outfile} {
    set in [open $pdbFile r ]
    set out [open $outfile a]
    foreach line [split [read $in] \n] {
	if {[string equal [string range $line 0 3] "ATOM"]} {
	    puts $out $line
	}
    }
    close $in
    close $out
}


#Computes lattice
proc box {offset}  {
    set all [atomselect top all]
    set minmax [measure minmax $all]
    set offset [list $offset $offset $offset]
    set box [vecsub [lindex $minmax 1] [lindex $minmax 0] ]
    set box [vecsub $box $offset]
    return $box
}

#Displaces boxes in every direction (x,y,z) by lattice vector
proc displacebox {outname box } {
    set all [atomselect top all]
    puts "box size  $box"
    set x 0.0
    set y 0.0
    set z 0.0 
    open $outname w
    for {set x 0} {$x <= 2} {incr x} {
	for {set y 0} {$y <= 2} {incr y} {	
	    for {set z 0} {$z <= 2} {incr z} {
		set Lx [expr $x*[lindex $box 0]]
		set Ly [expr $y*[lindex $box 1]]
		set Lz [expr $z*[lindex $box 2]]
		set vector [list $Lx $Ly $Lz]
		#puts "box = $x $y $z"
		$all moveby $vector
		$all set segid "$x$y$z"
		$all writepdb $x.$y.$z.pdb
		writepdb_full $x.$y.$z.pdb $outname
		exec rm  $x.$y.$z.pdb
		$all moveby [vecscale -1 $vector]	
	    }
	}
    }
    $all delete
}

#Checks if main molecule crosses PBC
proc check_cross {selection box} {
    set min_max  [measure minmax [atomselect top $selection]]
    set distance_vec [vecsub [lindex $min_max 1] [lindex $min_max 0] ]
    foreach distance $distance_vec l $box {
	if {$distance >= $l } {
	    return 1
	}
        incr i
    } 
    return 0
}


proc gather {resname segname box outname} {
    
    set first [lindex [ [atomselect top "segid $segname and resname $resname"] get index ] 0]
    puts $first
    set pos_vec {}
    foreach i {x y z} {
	lappend pos_vec [[atomselect top "index $first"] get $i]
    }
    set half_box [vecscale 0.5 $box]
    set plus_vec [vecadd $pos_vec $half_box]
    set minus_vec [vecsub $pos_vec $half_box]
    set min_x [lindex $minus_vec 0]
    set max_x [lindex $plus_vec 0]
    set min_y [lindex $minus_vec 1]
    set max_y [lindex $plus_vec 1]
    set min_z [lindex $minus_vec 2]
    set max_z [lindex $plus_vec 2]
    set sel [atomselect top "x >= $min_x and y >= $min_y  and z >= $min_z and x <= $max_x and y <= $max_y  and z <= $max_z"]
    $sel writepdb $outname  
}

######MAIN######
proc main {} {
    global inPDB outPDB center_selection offset box  resname segname box outname
    mol delete all
    mol load pdb $inPDB
    
    #set box [box 1]

    if {[check_cross $center_selection $box]} {
	displacebox  $outPDB $box
	mol delete all
	mol load pdb $outPDB
	set all [atomselect top all]
	$all writepdb $outPDB
	$all delete
	mol delete all
	mol load pdb $outPDB
	gather $resname $segname $box $outname
	mol delete all
	exec rm  $outPDB
	mol load pdb $outname
    }
}


