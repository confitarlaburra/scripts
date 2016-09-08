proc DeltaSasa { selT sel1 sel2  {mol top} } {
     set total [atomselect $mol "$selT"]
     set sel1  [atomselect $mol "$sel1"]
     set sel2  [atomselect $mol "$sel2"]

     set SasaComplex [measure sasa 1.4 $total]
     set SasaSel1 [measure sasa 1.4 $sel1]
     set SasaSel2 [measure sasa 1.4 $sel2]

     set DeltaSasa [expr ($SasaSel1 + $SasaSel2) - $SasaComplex]
     return $DeltaSasa
}



