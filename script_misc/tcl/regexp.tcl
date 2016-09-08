proc HbondExtractResidue {HbondFile} {
	set i 0
	set lista1 {}
	set lista2 {}
	set SuperLista {}
	set in [open input.dat r]
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

HbondExtractResidue {input.dat}
