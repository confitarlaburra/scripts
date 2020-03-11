#set Ca [atomselect top "protein and name CA"]
mol load pdb model.pdb
set all [atomselect top "all"]
#init
set j 110
#just to be consistent wih the original PDB numbering
set k 133
foreach index [$all get index] {
    set sel [atomselect top "index $index"]
    if {[$sel get resid]<=493} {
	$sel set resid [expr [$sel get resid] + $j]
    } else {
	$sel set resid [expr [$sel get resid] + $k]
    }
    $sel delete
}
$all writepdb modelRenum.pdb
$all delete
mol delete all

