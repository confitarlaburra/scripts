proc fit_2mol  { selection } {
         set ref [atomselect 1 "$selection"]
         set sel [atomselect top "$selection"]
         set all [atomselect top all]
         $all move [measure fit $sel $ref]
}


fit_2mol "segid MD2 and name CA"


set reslist {68 82 85 87 95 99 100 101 105 109 111 124 126}
set out [open rmsd_residues.dat w]
foreach resid $reslist {
        set rmsd [measure rmsd [atomselect 2 "protein and noh and resid $resid "] [atomselect 1 "protein and noh and resid $resid"]] 
        puts $out "$resid $rmsd"
}

close $out

for {set i 0} {$i < 10} {incr i} {
     set strand($i) 0

}
set strand(1) "protein and noh and resid 21 to 27"
set strand(2) "protein and noh and resid 30 to 37"
set strand(3) "protein and noh and resid 45 to 50"
set strand(4) "protein and noh and resid 57 to 66"
set strand(5) "protein and noh and resid 75 to 82"
set strand(6) "protein and noh and resid 85 to 94"
set strand(7) "protein and noh and resid 113 to 122"
set strand(8) "protein and noh and resid 129 to 140"
set strand(9) "protein and noh and resid 144 to 156"

set out [open rmsd_bstrands.dat w]
foreach i {1 2 3 4 5 6 7 8 9} {
        set rmsd [measure rmsd [atomselect top "$strand($i)"] [atomselect 1 "$strand($i)"]]
        puts $out "$i $rmsd"        
}
close $out
