## Remove water inside tube and renumbers fro gromos
## tube mus be centered with it main axis in the z direction ##



set input_name "8.8_3nm_100_methane_water"
set radius "9";
set max_z "15";
set min_z "-15";
set first_water "102"


mol load g96 $input_name.cnf

set good [atomselect top "not (same resid as (z > $min_z and z < $max_z) and (x**2 + y**2 < $radius))"]
#set good [atomselect top "not (same resid as (z > $min_z and z < $max_z and (x**2 + y**2 < $radius))) "]
$good writepdb $input_name.pdb
mol delete all
mol load pdb $input_name.pdb
#renumber solvent

set solvent [atomselect top "resname SOLV"]
set j $first_water
set i 0
foreach  x [$solvent get index] {
	set sel [atomselect top "index $x"]
	if {$i%3 == 0} {incr j}
	incr i
#	puts "$x $i $j"
	$sel set resid $j
}

set j 0
set i 0

set all [atomselect top all]
$solvent writepdb $input_name.solvent.pdb
mol delete all
mol load pdb $input_name.solvent.pdb
exit
