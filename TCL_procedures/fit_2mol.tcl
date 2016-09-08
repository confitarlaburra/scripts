proc fit_2mol  { selection } {
         set ref [atomselect 0 "$selection"]
         set sel [atomselect top "$selection"]
         set all [atomselect top all]
         $all move [measure fit $sel $ref]
}

