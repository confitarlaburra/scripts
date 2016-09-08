proc build_CNT { n m length } {
    package require nanotube
    nanotube -l $length -n $n -m $m
    set all [atomselect top all]
    $all writepdb "$n.$m.raw.pdb"
}


proc rename_CNT {resname  outname sel} {
    set sel [atomselect top "$sel"]
    set i 1
    foreach index [$sel get index] {
	set single [atomselect top "index $index"]
	$single set resname CNT
	$single set resid 1
	$single set name C$i
	incr i
    } 
    $sel writepdb "$outname.pdb"
}

proc build_topo_CNT {sel type mass charge outname } {
    package require topotools
    set sel [atomselect top "$sel"]
    $sel set type CA
    $sel set mass $mass
    $sel set charge $charge
    mol bondsrecalc top
    topo retypebonds
    topo guessangles
    topo guessdihedrals
    mol reanalyze top
    animate write psf "$outname.psf"
}
