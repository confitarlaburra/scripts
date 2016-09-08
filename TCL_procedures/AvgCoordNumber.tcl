#selection 1 main atoms to be coordinated with
#selection 2 coordinations atoms
#Cutoff in A

proc AvgCoordNumb {{mol top} selection1 selection2 cutoff} {
     set sel1 [atomselect $mol "$selection1"]
     set index_list [$sel1 get index] 
     set sum 0.00
     set atom_number [llength $index_list]
     set coordList {}
     foreach index $index_list {
	set sel [atomselect $mol "$selection2 and within $cutoff of index $index"]
        lappend coordList [$sel num]
     }
     foreach coord $coordList {
	set sum [expr $sum + $coord]
     }
     set avg [expr $sum/$atom_number]
     set sum 0.00
     foreach coord $coordList {
	set sum [expr $sum + ($coord - $avg)*($coord - $avg)]
     }
     set sd [expr sqrt ($sum/$atom_number)]
     set avg [format "%3.3f" $avg]
     set sd  [format "%3.3f" $sd]
     return "$avg $sd" 
}

#Example of use:
#AvgCoordNumb top "name PA PB PG" "name NA" 20
