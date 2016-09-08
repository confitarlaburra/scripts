# writes a z ordered load for periodic tubes (dist rest DG calculations)
# Input Variable
#input pdb witn only the loeade molecules
set pdb_traj final.pdb
# ref with tube aligned in z
set ref_cnf  eq_CNT_26CH3OH_5.cnf
set min_z -16
set max_z  16
set radius 3.8
set tube_sel_text "resname CCC"
set fit_sel_text "resname CCC"
set load_sel_text "resname C3OH"
set tube_name "6.6_3nm"
#frame chosen for load
set frame 1




#reads pdb and and concatenates them in a single file
proc concat_pdbs {outname molecules} {
    set out [open $outname.pdb w]
    for {set i 0} {$i < $molecules} {incr i} {
	set number [expr $i+1]	
	set inStream [open 0$number.pdb r]
	foreach line [split [read $inStream] \n] {
	    set string0 [string range $line 0 3]
	    if {[string match $string0 "ATOM"]} {
		puts $out  $line
	    }	
	}
	close $inStream
    }
    close $out
}


proc concat_pdb_list {pdb_list outname} {
    set out [open $outname.pdb w]
    foreach pdb $pdb_list {	
	set inStream [open $pdb r]
	foreach line [split [read $inStream] \n] {
	    set string0 [string range $line 0 3]
	    if {[string match $string0 "ATOM"]} {
		puts $out  $line
	    }	
	}
	close $inStream
    }
    close $out
}




#finds residue with lowes values for z coordinate
proc find_min_z {rest_list max} {
    set min $max
    set min_index 0
    foreach res $rest_list {
	set z [lindex [measure center [atomselect top "resid $res"]] 2]
	if {$z < $min} {
	    set min $z
	    set min_residue $res	
	} 
    }
    return $min_residue
}


#fit a trajecotry based on first frame
proc fit { {mol top} selection  } {
     
    set ref [atomselect $mol "$selection" frame 0]
    set sel [atomselect top "$selection"]
    set all [atomselect top all]
    set nf [molinfo $mol get numframes]
    for {set frame 0} {$frame < $nf} {incr frame} {
	$sel frame $frame
	$all frame $frame 
	$all move [measure fit $sel $ref]
    }

} 


## MAIN ##
proc main {} {
    global pdb_traj ref_cnf min_z max_z radius tube_sel_text fit_sel_text load_sel_text frame tube_name
    #select loaded particles
    mol delete all
    mol load g96 $ref_cnf
    set all [atomselect top all]
    set tube [atomselect top "$tube_sel_text"]
    $all moveby [vecinvert [measure center $tube]]
    $tube writepdb $tube_name.pdb
    mol addfile $pdb_traj waitfor all
    fit top $fit_sel_text
    set frame_sel_text "same resid as ($load_sel_text  and ( (x**2 + y**2) < $radius**2) and z > $min_z and z < $max_z )" 
    set frame_sel [atomselect top $frame_sel_text frame $frame]
    set mol_number [llength [$frame_sel get resname]]
    set residue [lindex [$frame_sel get resname] 0]
    $frame_sel writepdb  $mol_number.$residue.pdb
    #$all delete
    mol delete all
    
    ## order based on z position
    mol load pdb  $mol_number.$residue.pdb
    set all [atomselect top all]
    set rest_list [$all get resid]
    set list_size [llength $rest_list]
    set list_size [expr $list_size]

    #here we have issues for load > 1

    for {set i 0} {$i < $list_size} {incr i} {
	set number [expr $i]
	set resid [find_min_z $rest_list $max_z]
	set selection [atomselect top "resid $resid"]
	$selection set resid $number
	$selection writepdb "0$number.pdb"
	set idx [lsearch $rest_list $resid]
	set rest_list [lreplace $rest_list $idx $idx]
	$selection delete		
    }
    #$all delete
    mol delete all
    concat_pdbs $mol_number.$residue $mol_number
    #Delete unwanted files
    for {set i 0} {$i < $list_size} {incr i} {
	set number [expr $i+1]
	file delete "0$number.pdb"
    }
    #load pdb and renumber it with vmd	
    mol load pdb $mol_number.$residue.pdb
    set all [atomselect top all]
    $all writepdb $mol_number.$residue.pdb
    mol delete all
    set name1 $mol_number.$residue.pdb
    set name2 $tube_name.pdb
    set pdb_list {}
    lappend pdb_list $name1 $name2
    concat_pdb_list $pdb_list $mol_number.$residue.$tube_name
    mol load pdb $mol_number.$residue.$tube_name.pdb
    set all [atomselect top all]
    $all writepdb $mol_number.$residue.$tube_name.pdb
}

## Run program
main
exit
