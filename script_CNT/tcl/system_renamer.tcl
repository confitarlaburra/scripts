
### Pwater "resname of CNT" "radius" "solvent Oxygen name" "solvent resname" "z (pore axis) offset)
proc PwaterSel {nanoRes radius waterO solventName offset } {
	set wat  [atomselect top "name   $waterO"]
	set nano [atomselect top "resname $nanoRes"]
	set water_selection "resname $solventName and resid " 
	set nano_min_max [measure minmax $nano]
  	set min_xyz [lindex $nano_min_max 0]
  	set max_xyz [lindex $nano_min_max 1]
  	set min_z [lindex $min_xyz 2]
  	set max_z [lindex $max_xyz 2] 
	set nano_center [measure center $nano]
	set center_x [lindex $nano_center 0]
	set center_y [lindex $nano_center 1]
	foreach z [$wat get z] x [$wat get x] y [$wat get y] resid [$wat get resid]  {
		if { $z > [expr $min_z - $offset] && $z < [expr $max_z + $offset] } {
			set delta_x  [expr $x - $center_x]
			set delta_y  [expr $y - $center_y]
			set distance [expr sqrt ($delta_x*$delta_x + $delta_y*$delta_y)]
			if {$distance <= $radius} {set water_selection "$water_selection $resid " }
		}			
	}
	$wat delete
	$nano  delete
	return $water_selection
}

### PwaterRenamer "Selection " "init index" "new resname"
proc  PwaterRenamer {selection ResidInitIndex NewResname}	{	
	set water [atomselect top "$selection"]	
	set idwat [$water get index]    
	if { [llength $idwat] != 0 } {
		set i $ResidInitIndex		
	    	for {set j 0} {$j < [expr [llength $idwat] / 3 ]} {incr j} {
			incr i	
			set k [expr $j *3]
                	set oxygen_index  [ lindex $idwat [expr $k + 0] ]
			set selection [atomselect top "index $oxygen_index"]
			$selection set resid $i
			$selection set resname $NewResname
			set H1_index      [ lindex $idwat [expr $k + 1] ]
			set selection [atomselect top "index $H1_index"]
			$selection set resid $i
			$selection set resname $NewResname
			set H2_index      [ lindex $idwat [expr $k + 2] ]
			set selection [atomselect top "index $H2_index"]
			$selection set resid $i
			$selection set resname $NewResname			              
		}			
	}

	$selection delete
}	


proc solventOffset {solvResName offset} {
	set water [atomselect top "resname $solvResName"]	
	set idwat [$water get index]
	set offset $offset    
	if { [llength $idwat] != 0 } {
		set i 0		
	    	for {set j 0} {$j < [expr [llength $idwat] / 3 ]} {incr j} {
			incr i	
			set k [expr $j *3]
                	set oxygen_index  [ lindex $idwat [expr $k + 0] ]
			set selection [atomselect top "index $oxygen_index"]
			$selection set resid [expr [$selection get resid ] +$offset]
			set H1_index      [ lindex $idwat [expr $k + 1] ]
			set selection [atomselect top "index $H1_index"]
			$selection set resid [expr [$selection get resid ] +$offset]
			set H2_index      [ lindex $idwat [expr $k + 2] ]
			set selection [atomselect top "index $H2_index"]
			$selection set resid [expr [$selection get resid ] +$offset]	
              
		}			
	}
	$selection delete	
}

#### Main ####
###Gromos topology needs  to start with with water CNT and then the CNT 

set inputPDB         "6.6.water.pdb"
set NewNameResSolv   "H2O"
set SolvResName      "SOLV"
set OxSolvResName    "OW"
set CNTResName       "CCC"
set CNT_radius       "4.0"
set CNT_zOffSet      "2.0"
mol load pdb $inputPDB

##Selection of waters within the CNT
set WatersCNT [PwaterSel $CNTResName $CNT_radius $OxSolvResName $SolvResName $CNT_zOffSet]; ### Pwater "resname of CNT" "radius" "solvent Oxygen name" "solvent resname" "z (pore axis) offset) 
set NwaterCNT [expr  [llength [[atomselect top "$WatersCNT"] get resid] ]/3] ; ### Get Water Number inside CNT
###Renaming the selected waters 
PwaterRenamer $WatersCNT 0 $NewNameResSolv;                    ### PwaterRenamer "Selection " "init index" "new resname"
###### Rename CNT
set CNT [atomselect top "resname CCC"]
$CNT set resid     [expr  $NwaterCNT + 1 ]

solventOffset SOLV [expr $NwaterCNT +  1 ]

set all [atomselect top all]
$all writepdb temp.pdb
mol delete all
#first water CNT, CNT, solvent
exec grep $NewNameResSolv  temp.pdb >  temp2.pdb
exec grep $CNTResName      temp.pdb >> temp2.pdb
exec grep $SolvResName     temp.pdb >> temp2.pdb 
#reload with VMD to get atom renumbering
mol load pdb temp2.pdb
set all [atomselect top all]
$all writepdb $inputPDB.renamed.pdb
exec rm temp.pdb temp2.pdb
exit




