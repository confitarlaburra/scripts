proc Saltbrdige { {mol top} { residue } {selection2} {cutoff 4} {out} } {
     
      if     {$residue eq "ARG"} { 
             set selection [atomselect top "resname $residue and name CZ"]
             set atom "CZ" 
      } elseif {$residue eq "LYS"} {
             set selection [atomselect top "resname $residue and name NZ"]
             set atom "NZ"      
      } elseif {$residue eq "ASP"} { 
             set selection [atomselect top "resname $residue and name CG"]
             set atom "CG"
      } else { 
             set selection [atomselect top "resname $residue and name CD"]
             set atom "CD"
      }	  
      set reslist [$selection get resid]
      set centerSel2 [measure center [atomselect top "$selection2"]]
      
      set out [open $out.dat a+]
      foreach resid $reslist {              
	      set distance($resid) [veclength [vecsub [measure center [atomselect top "protein and resid $resid and name $atom"]] $centerSel2]]
              if {$distance($resid) <= $cutoff} {set contact($resid) 1} else {set contact($resid) 0}              
      } 
      set bigcolumn "" 
      foreach resid $reslist {
             set bigcolumn "$bigcolumn $resid $distance($resid) $contact($resid)"
      }
      puts $out $bigcolumn
      close $out
      return $bigcolumn
}


proc ResID { {mol top} { residue } {out} } {

      if     {$residue eq "ARG"} {
             set selection [atomselect top "resname $residue and name CZ"]
             set atom "CZ"
      } elseif {$residue eq "LYS"} {
             set selection [atomselect top "resname $residue and name NZ"]
             set atom "NZ"
      } elseif {$residue eq "ASP"} {
             set selection [atomselect top "resname $residue and name CG"]
             set atom "CG"
      } else {
             set selection [atomselect top "resname $residue and name CD"]
             set atom "CD"
      }
      set reslist [$selection get resid]

      set out [open $out.dat a+]
      set bigcolumn "# "
      foreach resid $reslist {
             set bigcolumn "$bigcolumn       $residue $resid"
      }
      puts $out $bigcolumn
      close $out
      return $bigcolumn
}
      
