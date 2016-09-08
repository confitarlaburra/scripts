#Script that places a NT in a POPC membrane and solvates it with a 10A layer of water


#Here put the pdb of the nanotube (the lenght of the NT should be equal of higher to 37A and its principal axix must be aligned to the z axix)
#Topology containing the topology of the NT
#define vec_x and vec_y for the desired size of the membrane   


set input_pdb "n6.pdb"
set topology "top_all27_prot_lipid_nano6.inp"
set vec_x 40
set vec_y 40

package require psfgen                      
topology $topology

segment NT {pdb $input_pdb}
coordpdb $input_pdb NT

regenerate angles                       
regenerate dihedrals
writepsf $input_pdb.psf
writepdb $input_pdb.pdb

mol delete all

#Loads the NT system  and builds an apropiate POPC membrane, 
#then aligns both the membrane and the NT and makes a psf file of the mebrane NT system 

set nano_tet_mol [mol load psf $input_pdb.psf pdb $input_pdb.pdb]

set nano_tet [atomselect $nano_tet_mol all]
$nano_tet moveby [vecinvert [measure center $nano_tet weight mass]]
$nano_tet writepdb $input_pdb.TEMP.pdb

package require membrane
membrane -l POPC -x $vec_x -y $vec_y  

set membrane_mol  [mol load psf membrane.psf pdb membrane.pdb]
set membrane [atomselect $membrane_mol all]
$membrane moveby [vecinvert [measure center $membrane weight mass]]
$membrane writepdb membrane_TEMP.pdb

mol delete all

package require psfgen
topology $topology
resetpsf
readpsf $input_pdb.psf
coordpdb $input_pdb.TEMP.pdb
readpsf membrane.psf
coordpdb membrane_TEMP.pdb
writepdb $input_pdb.raw.pdb
writepsf $input_pdb.raw.psf


#loads the NT membrane system and removes the overlaping water and phospholipids molecules
#and makes a new psf and pdb   

mol load psf $input_pdb.raw.psf pdb $input_pdb.raw.pdb
set POPC "resname POPC"
set all [atomselect top all]
$all set beta 0
set seltext3 "segname L01 to L80  and same residue as (within 0.6 of resname ARM)"
set sel3 [atomselect top $seltext3]
$sel3 set beta 1
set badlipid [atomselect top "beta >0"]
set seglistlipid [$badlipid get segid]
set reslistlipid [$badlipid get resid]
set seltext4 "segname w1 to w80 and same residue as (within 2.0 of resname ARM)"
set seltext5 "segname W1 to W80 and same residue as (within 2.0 of resname ARM)"
set sel4 [atomselect top $seltext4]
set sel5 [atomselect top $seltext5]
$sel4 set beta 1
$sel5 set beta 1
set badwater [atomselect top "name OH2 and beta >0"]
set seglistwater [$badwater get segid]
set reslistwater [$badwater get resid]
mol delete all
package require psfgen
resetpsf
readpsf $input_pdb.raw.psf
coordpdb $input_pdb.raw.pdb
foreach segid $seglistlipid resid $reslistlipid {
	delatom $segid $resid
	}
foreach segid $seglistwater resid $reslistwater {
	delatom $segid $resid
	}
writepsf $input_pdb.popc.psf
writepdb $input_pdb.popc.pdb


#loads the NT membrane system with the overlaping molecules removed, get its size
#according to its size solvates the system with water (10A layer in the z axis) 
#and removes the waters located inside the membrane 

mol load psf $input_pdb.popc.psf pdb $input_pdb.popc.pdb
set water [atomselect top water]

set minmax [measure minmax $water ]
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

set box_z_vec_1 [expr $max_z + 10]
set box_z_vec_2 [expr $min_z - 10] 

mol delete all
 
package require solvate
solvate $input_pdb.popc.psf $input_pdb.popc.pdb -o $input_pdb.popc.TEMP -b 1.5 -minmax "{$min_x $min_y $box_z_vec_2} {$max_x $max_y $box_z_vec_1}"

set all [atomselect top all]
$all set beta 0
set seltext "segid WT1 to WT99 and same residue as abs(z) <25"
set sel [atomselect top $seltext]
$sel set beta 1
set badwater [atomselect top "name OH2 and beta > 0"]
set seglist [$badwater get segid]
set reslist [$badwater get resid]
mol delete all
package require psfgen
resetpsf
readpsf $input_pdb.popc.TEMP.psf
coordpdb $input_pdb.popc.TEMP.pdb
foreach segid $seglist resid $reslist {
	delatom $segid $resid
	}
writepdb $input_pdb.popc.water.pdb
writepsf $input_pdb.popc.water.psf

#Deletes intermediate files, comment this part if you want to have them

file delete $input_pdb.psf
file delete $input_pdb.pdb
file delete $input_pdb.TEMP.pdb
file delete membrane.psf
file delete membrane.pdb
file delete membrane_TEMP.pdb
file delete $input_pdb.popc.pdb
file delete $input_pdb.popc.psf
file delete $input_pdb.popc.TEMP.psf
file delete $input_pdb.popc.TEMP.pdb
file delete combine.psf
file delete combine.pdb
file delete $input_pdb.raw.psf 
file delete $input_pdb.raw.pdb
file delete $input_pdb.popc.TEMP.log

#loads the final NT_membrane system, and get its size and center for a future MD simulation
mol load psf $input_pdb.popc.water.psf pdb $input_pdb.popc.water.pdb

set water [atomselect top water]
set minmax [measure minmax $water ]
set center [measure center $water ]
set out [open center_min_max.txt w]

puts $out "Center of the system: $center\n Min_Max of the sytem: $minmax"
close $out

