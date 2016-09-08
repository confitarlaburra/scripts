proc fit_bigdcd { {mol top} selection } {
    
     set ref [atomselect $mol "$selection" frame 0]
     set sel [atomselect top "$selection"]
     set all [atomselect top all]
     $all move [measure fit $sel $ref]
} 

