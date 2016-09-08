mol new MD2_LipidA_TLR4.solv.box.ion.psf
mol addfile eq4.vel type namdbin waitfor all

set fil [open energy.dat w]

set all [atomselect top "not water"]

foreach m [$all get mass] v [$all get {x y z}] {
	puts $fil [expr 0.5* $m * [vecdot $v $v]]
}
close $fil
