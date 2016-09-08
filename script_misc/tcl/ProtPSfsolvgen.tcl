#input variables
set pdbname "arg"
set psfname "arg"
set residue "resname ARG"
set selection "water and same residue as (within 2.4 of $residue)"
set cutoff 12
set IonConc 0.05 ; # mol/L
set neutralize 1
set fixed $residue
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
    
     set min [expr min($min_x,$min_y,$min_z)]
     set max [expr max($max_x,$max_y,$max_z)]

     set x_box_size_min [expr $min - $cutoff]
     set x_box_size_max [expr $max + $cutoff]

     set y_box_size_min [expr $min - $cutoff]
     set y_box_size_max [expr $max + $cutoff]


     set z_box_size_min [expr $min - $cutoff]
     set z_box_size_max [expr $max + $cutoff]
      
     
     set box_x [expr abs($min)+ abs($max) + 2*$cutoff ] 
     set box_y [expr abs($min)+ abs($max) + 2*$cutoff ]
     set box_z [expr abs($min)+ abs($max) + 2*$cutoff ]
     
     set box_min_max " $x_box_size_min $y_box_size_min $z_box_size_min $x_box_size_max  $y_box_size_max  $z_box_size_max"
     set box " $box_x $box_y $box_z "
     return "$box_min_max $box"
}




#load solvated_molecule and center it
mol load psf $pdbname.psf pdb $pdbname.pdb
set all [atomselect top all]
$all moveby [vecinvert [measure center $all]]
$all writepdb $pdbname.pdb
#get min max of solute (e.g. protein)
set box [box_size "$residue" $cutoff]

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
readpsf $pdbname.psf
coordpdb $pdbname.pdb
readpsf box.psf
coordpdb box.pdb
writepsf $pdbname.box.RAW.psf
writepdb $pdbname.box.RAW.pdb
resetpsf
file delete box.pdb
file delete box.psf
#Delete unwanted atoms
mol load psf $pdbname.box.RAW.psf pdb $pdbname.box.RAW.pdb
set bad [atomselect top "$selection"]
set seglist [$bad get segid]
set reslist [$bad get resid]
mol delete all
resetpsf
readpsf  $pdbname.box.RAW.psf
coordpdb $pdbname.box.RAW.pdb
foreach segid $seglist resid $reslist {
delatom $segid $resid
}
writepsf $pdbname.box.psf
writepdb $pdbname.box.pdb
file delete $pdbname.box.RAW.psf
file delete $pdbname.box.RAW.psf
#ionize
if ($neutralize) {
	autoionize -neutralize -psf $pdbname.box.psf -pdb $pdbname.box.pdb -o $pdbname.box.ion
} else {autoionize -sc 0.05 -psf $pdbname.box.psf -pdb $pdbname.box.pdb -o $pdbname.box.ion}
file delete $pdbname.box.psf
file delete $pdbname.box.pdb
#load final system and get min max for future MD
mol load psf $pdbname.box.ion.psf pdb $pdbname.box.ion.pdb
set all [atomselect top all]
$all set beta 0
set fixed [atomselect top "$fixed"]
$fixed set beta 1
$all writepdb $pdbname.box.ion.fix
set box [box_size "all" 0]
set out [open min_max.txt w]
puts $out "min max (x,y,z) and total is :$box"
close $out
