proc distance {{mol top} selection1 selection2 } {
     set coord1 [measure center [atomselect top "$selection1"]]
     set coord2 [measure center [atomselect top "$selection2"]]
     set distance [veclength [vecsub $coord1 $coord2]]
     return $distance
}

proc distanceFirst {{mol top} selection1 selection2 } {
     set coord1 [measure center [atomselect top "$selection1" frame 0]]
     set coord2 [measure center [atomselect top "$selection2"]]
     set distance [veclength [vecsub $coord1 $coord2]]
     return $distance
}

