proc fit { {mol top} selection refFrame  } {
     
     set ref [atomselect $mol "$selection" frame $refFrame]
     set sel [atomselect top "$selection"]
     set all [atomselect top all]
     set nf [molinfo $mol get numframes]
     for {set frame 0} {$frame < $nf} {incr frame} {
         $sel frame $frame
         $all frame $frame 
     	 $all move [measure fit $sel $ref]
     }

} 
