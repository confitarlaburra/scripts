#input variables
set pdbname " MD2.C60"
set psfname " MD2.C60"
set selection "not segid WS and water and same residue as (within 2.8 of resname FU2 or protein or segid WS)"
set topology_path "/home/fett/work/script/topologies/toppar_water_ions.str"
set cutoff 12.5
set IonConc 0.05 ; # mol/L
set neutralize 1
set fixed "protein or resname FU2"
#procedure to get min max + cutoff of solute
proc box_size { sel cutoff } {
     set minmax [measure minmax [atomselect top "$sel"]]
     set min_xyz [lindex $minmax 0]
     set max_xyz [lindex $minmax 1]
     
     set min_x [lindex $min_xyz 0]
     set max_x [lindex $max_xyz 0]

     set min_y [lindex $min_xyz 1]
     set max_y [lindex $max_xyz 1]  

     set min_y [lindex $min_xyz 1]
     set max_y [lindex $max_xyz 1]

     set min_z [lindex $min_xyz 2]
     set max_z [lindex $max_xyz 2]
    
     set x_box_size_min [expr $min_x - $cutoff]
     set x_box_size_max [expr $max_x + $cutoff]

     set y_box_size_min [expr $min_y - $cutoff]
     set y_box_size_max [expr $max_y + $cutoff]


     set z_box_size_min [expr $min_z - $cutoff]
     set z_box_size_max [expr $max_z + $cutoff]
      
     
     set box_x [expr abs($min_x)+ abs($max_x) + 2*$cutoff ] 
     set box_y [expr abs($min_y)+ abs($max_y) + 2*$cutoff ]
     set box_z [expr abs($min_z)+ abs($max_z) + 2*$cutoff ]
     
     set box_min_max " $x_box_size_min $y_box_size_min $z_box_size_min $x_box_size_max  $y_box_size_max  $z_box_size_max"
     set box " $box_x $box_y $box_z "
     return "$box_min_max $box"
}

#solvate molecules using external program solvate
#exec solvate -t 3 -n 8 -w $pdbname solvate
package require psfgen
#generate psf and pdb of solvated molecule
topology $topology_path
segment WS {pdb solvate.pdb}
coordpdb solvate.pdb WS
readpsf  $psfname.psf
coordpdb $pdbname.pdb
writepsf $pdbname.solv.psf
writepdb $pdbname.solv.pdb
resetpsf
#file delete solv.pdb
#load solvated_molecule and center it
mol load psf $pdbname.solv.psf pdb $pdbname.solv.pdb
set all [atomselect top all]
$all moveby [vecinvert [measure center $all]]
$all writepdb $pdbname.solv.pdb
#get min max of solute (e.g. protein)
set box [box_size "protein" $cutoff]

set min_x [lindex $box 0]
set max_x [lindex $box 3]

set min_y [lindex $box 1]
set max_y [lindex $box 4]  

set min_z [lindex $box 2]
set max_z [lindex $box 5]

#Generate water box and combine it with solute.solvent
solvate -o box -minmax "{$min_x $min_y $min_z} {$max_x $max_y $max_z}"
mol delete all
resetpsf
readpsf $pdbname.solv.psf
coordpdb $pdbname.solv.pdb
readpsf box.psf
coordpdb box.pdb
writepsf $pdbname.solv.box.RAW.psf
writepdb $pdbname.solv.box.RAW.pdb
resetpsf
file delete $pdbname.solv.psf
file delete $pdbname.solv.pdb
file delete box.pdb
file delete box.psf
#Delete unwanted atoms
mol load psf $pdbname.solv.box.RAW.psf pdb $pdbname.solv.box.RAW.pdb
set bad [atomselect top "$selection"]
set seglist [$bad get segid]
set reslist [$bad get resid]
mol delete all
resetpsf
readpsf  $pdbname.solv.box.RAW.psf
coordpdb $pdbname.solv.box.RAW.pdb
foreach segid $seglist resid $reslist {
delatom $segid $resid
}
writepsf $pdbname.solv.box.psf
writepdb $pdbname.solv.box.pdb
file delete $pdbname.solv.box.RAW.psf
file delete $pdbname.solv.box.RAW.psf
#ionize
if ($neutralize) {
	autoionize -neutralize -psf $pdbname.solv.box.psf -pdb $pdbname.solv.box.pdb -o $pdbname.solv.box.ion
} else {autoionize -sc 0.05 -psf $pdbname.solv.box.psf -pdb $pdbname.solv.box.pdb -o $pdbname.solv.box.ion}
file delete $pdbname.solv.box.psf
file delete $pdbname.solv.box.pdb
#load final system and get min max for future MD
mol load psf $pdbname.solv.box.ion.psf pdb $pdbname.solv.box.ion.pdb
set all [atomselect top all]
$all set beta 0
set fixed [atomselect top "$fixed"]
$fixed set beta 1
$all writepdb $pdbname.solv.box.ion.fix
set box [box_size "all" 0]
set out [open min_max.txt w]
puts $out "min max (x,y,z) and total is :$box"
close $out
