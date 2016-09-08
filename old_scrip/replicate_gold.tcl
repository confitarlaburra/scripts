set pdb_name gold_ortho_unit.pdb
set top_file gold.top
set lattice_x 20.51
set lattice_y 18.15
set nx 5
set ny 5

mol load pdb $pdb_name
set all [atomselect top all]

for {set t 1} {$t <= $ny} {incr t} {
	$all writepdb $t.1.pdb
	for {set i 2} {$i <= $nx} {incr i} {
		$all moveby "$lattice_x 0 0"
		$all writepdb $t.$i.pdb	
	}
	mol delete all
        mol load pdb $t.1.pdb
	set all [atomselect top all]
	$all moveby "0 $lattice_y 0"
	    
}

mol delete all

package require psfgen
resetpsf
topology $top_file

for {set t 1} {$t <= $ny} {incr t} {
	for {set i 1} {$i <= $nx} {incr i} {
		segment S$t.$i {pdb $t.$i.pdb }
		coordpdb $t.$i.pdb S$t.$i
	}

}

writepsf $nx.$ny.surface.psf
writepdb $nx.$ny.surface.pdb

for {set t 1} {$t <= $ny} {incr t} {
	for {set i 1} {$i <= $nx} {incr i} {
		file delete $t.$i.pdb
	}

}
mol load psf $nx.$ny.surface.psf pdb $nx.$ny.surface.pdb
