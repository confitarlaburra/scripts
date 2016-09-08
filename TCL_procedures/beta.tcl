proc beta {  {selection} {pdb_name} {mol top} } {
	set all [atomselect top all]
	$all set beta 0
	set fixed [atomselect top "$selection"]
	$fixed set beta 1
	$all writepdb $pdb_name
}
