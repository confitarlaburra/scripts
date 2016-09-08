proc harmonic {selection1 selection2 frame {k 1} {exp 2} {reference_frame 0} {mol top} } {
     #set coord1 [[atomselect top "$selection1"] get {x y z}]
     #set coord2 [[atomselect top "$selection2"] get {x y z}]
     set coord1 [measure center [atomselect top "$selection1" frame $reference_frame]]
     set coord2 [measure center [atomselect top "$selection2" frame $frame]]
     set distance [veclength [vecsub $coord1 $coord2]]
     set elevated 1
     for {set i 1} {$i <= $exp} {incr i} {
         set elevated [expr $elevated*$distance]
     } 
     set HarmonicEnergy [expr $k*$elevated]
     return $HarmonicEnergy
}

