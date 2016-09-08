#Procedure that read hbond analysis output and returns 
# a super list with the pairs of residue involved
# in the hbond {{resname resid} {resname resid}(1st pair) {resname resid } {resname resid} (2nd pair) etc...}
proc HbondExtractResidue {HbondFile} {
	set i 0
	set lista1 {}
	set lista2 {}
	set SuperLista {}
	set in [open $HbondFile r]
        foreach line [split [read $in] \n] {
			 if {[regexp {^(\D+)(\d+)\S+\s+(\D+)(\d+)} $line match resname1 resid1 resname2 resid2] } {
				set i 1		
                         	lappend lista1 $resname1 $resid1 
				lappend lista2 $resname2 $resid2		       
			 } else { set i 0}

			if {$i == 1} {lappend SuperLista $lista1 $lista2}				
			set lista1 {}
			set lista2 {}
			

	}
	return $SuperLista
}

if {0} {
proc SideChainSelComDistance {List} {
	for {set i 0} {$i < [llength $List]} {set i [expr $i + 2] } {
		set j [expr $i +1]	
		set pair1          [lindex $List $i]
		set pair2          [lindex $List $j]
		set pair1Resname   [lindex $pair1 0]
		set pair1Resid     [lindex $pair1 1]
		set pair2Resname   [lindex $pair2 0]
		set pair2Resid     [lindex $pair2 1]
		if { [ [atomselect top "resname $pair1Resname and resid $pair1Resid and name CA"] get resname] eq "GLY" } {
			 set SideSel($i,1)  [atomselect top "resname $pair1Resname and resid $pair1Resid and noh"]	
		} else { set SideSel($i,1)  [atomselect top "resname $pair1Resname and resid $pair1Resid and sidechain and noh"]}

		if { [ [atomselect top "resname $pair2Resname and resid $pair2Resid and name CA"] get resname] eq "GLY" } {
			set SideSel($i,2)  [atomselect top "resname $pair2Resname and resid $pair2Resid and noh"]	
		} else {set SideSel($i,2)  [atomselect top "resname $pair2Resname and resid $pair2Resid and sidechain and noh"]}
		
	}
	array get SideSel
}
}
if {0} {
proc HbondsSelections { List } {
	for {set i 0} {$i < [llength $List]} {set i [expr $i + 2] } {
		set j [expr $i +1]	
		set pair1          [lindex $List $i]
		set pair2          [lindex $List $j]
		set pair1Resname   [lindex $pair1 0]
		set pair1Resid     [lindex $pair1 1]
		set pair2Resname   [lindex $pair2 0]
		set pair2Resid     [lindex $pair2 1]
		set HbondSel($i,1) [atomselect top "(resname $pair1Resname and resid $pair1Resid) and (name \"N.*\" \"O.*\" \"S.*\" FA F1 F2 F3)"]
	        set HbondSel($i,2) [atomselect top "(resname $pair2Resname and resid $pair2Resid) and (name \"N.*\" \"O.*\" \"S.*\" FA F1 F2 F3)"]
	}
	array get HbondSel ;# no srive pq le pasa valores literales de los atomselect... :(
}
}
