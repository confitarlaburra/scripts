proc Sasa { sel  {mol top} } {
     set sel [atomselect $mol "$sel"]
     set Sasa [measure sasa 1.4 $sel]
     return $Sasa
}

