proc COM { {mol top} {selection} } {
     set sel [atomselect $mol "$selection"]
     set COM [measure center $sel weight mass]
     return $COM
}
