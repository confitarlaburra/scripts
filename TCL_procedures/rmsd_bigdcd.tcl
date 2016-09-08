proc rmsd_bigdcd { {mol top} selection } {
    
     set ref [atomselect $mol "$selection" frame 0]
     set sel [atomselect top "$selection"]
     set all [atomselect top all]
     $all move [measure fit $sel $ref]
     set rmsd [measure rmsd $sel $ref]
     return $rmsd
} 


proc rmsd_bigdcd_2sel { {mol top} selection selection2 } {
    
     set ref  [atomselect $mol "$selection" frame 0]
     set ref2 [atomselect $mol "$selection2" frame 0]
     set sel  [atomselect top "$selection"]
     set sel2 [atomselect $mol "$selection2" ]
     set all [atomselect top all]
     $all move [measure fit $sel $ref]
     set rmsd [measure rmsd $sel2 $ref2]
     return $rmsd
} 
