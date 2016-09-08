#PBC center system based on solute  JAG 14-11-13#

## Much easier with this simple command
## pbc wrap -center com -centersel "resname CNT" -all
## animate write dcd eq3_wrap.dcd $all
##
set reference ../equilibration/6.6_3nm_24CH4_water_min.cnf
set inPDB FRAME_00001.pdb
set center_selection "resname CCC"
set index_center 156
set offset 2
set ensemble NVT
set fitted 1
set box [ list 52.7 52.7 52.7]
set outTrajectory 6.6_24CH4.dcd
set resname CCC

# fitting procedure
source /home/fett/work/script/procedures/fit.tcl

#get box size (orthorombic)

proc box {offset}  {
    set all [atomselect top all]
    set minmax [measure minmax $all]
    set offset [list $offset $offset $offset]
    set box [vecsub [lindex $minmax 1] [lindex $minmax 0] ]
    set box [vecsub $box $offset]
    return $box
}


#gathers atoms with respect a selectio (center)
proc gather {resname  box index_center frame } {
    
    set first [lindex [ [atomselect top "resname $resname"] get index ] $index_center]
    set pos_vec {}
    set center_atom [atomselect top "index $first" frame $frame]
    $center_atom update
    foreach i {x y z} {
	lappend pos_vec [$center_atom get $i]
    }
    puts $pos_vec
    set half_box [vecscale 0.5 $box]
    set plus_vec [vecadd $pos_vec $half_box]
    set minus_vec [vecsub $pos_vec $half_box]
    set min_x [lindex $minus_vec 0]
    set max_x [lindex $plus_vec 0]
    set min_y [lindex $minus_vec 1]
    set max_y [lindex $plus_vec 1]
    set min_z [lindex $minus_vec 2]
    set max_z [lindex $plus_vec 2]
    set Natoms [ [atomselect top all] num]
    for {set i  0} {$i < $Natoms} {incr i} {
	set atom [atomselect top "index $i" frame $frame]
	$atom update
	set pos_atm {}
	foreach j {x y z} {
	    lappend pos_atm [$atom get $j]
	}
	
	set x [lindex $pos_atm 0]
	set y [lindex $pos_atm 1]
	set z [lindex $pos_atm 2]
	
	if { $x > $max_x } {
	    $atom set x [expr $x - [lindex $box 0 ]]
	}
	if { $y > $max_y } {
	    $atom set y [expr $y - [lindex $box 1 ]]
	}
	if { $z > $max_z } {
	    $atom set z [expr $z - [lindex $box 2 ]]
	}
	if { $x < $min_x } {
	    $atom set x [expr $x + [lindex $box 0 ]]
	}
	if { $y < $min_y } {
	    $atom set y [expr $y + [lindex $box 1 ]]
	}
	if { $z < $min_z } {
	    $atom set z [expr $z + [lindex $box 2 ]]
	}
	$atom delete
    }
}

######MAIN######
proc main {} {
    global inPDB outPDB center_selection offset box  resname segname box outname ensemble outTrajectory index_center reference fitted
    
    # Loads initial files
    mol delete all
    mol load g96 $reference  
    mol addfile $inPDB waitfor all
    
    #checks NVT or NPT
    if {$ensemble eq "NVT"} {
	set box $box
    } else {
	set box [box $offset]
    }

    # Cycle trough all frames and gather each snapshot
    set n [molinfo top get numframes]
    set all [atomselect top all]
    
    for { set i 0 } { $i < $n } { incr i } {
	$all frame $i
	puts "frame $i"
	$all update
	gather $resname  $box $index_center $i

    }
    #fit central molecule against initial frame, if required 
    if {$fitted} {    
	fit top $center_selection 0
    }
    #writes outpus in a dcd file and the first snapshot as a pdb and loads them
    set frame1 [atomselect top all frame 0]
    $frame1 writepdb 01.pdb
    $all delete
    set all [atomselect top all]
    animate write dcd $outTrajectory $all
    mol delete all
    mol load pdb 01.pdb
    mol addfile $outTrajectory waitfor all
        
}


