set radius 5.0
set solv_text "resname SOLV"
set cnf_name 15.ETOH.8.8_3nm.solv
set tube_sel_text "resname CCC"
set solv_selection "name OW"
set solv_resname "SOLV"


proc main {} {
    global radius  solv_text cnf_name tube_sel_text solv_resname solv_selection solv_resname
    mol load g96 $cnf_name.cnf
    set all [atomselect top all]
    set tube [atomselect top "$tube_sel_text"]
    $all moveby [vecinvert [measure center $tube]]
    set sel_text " not same resid as (resname $solv_resname and ((x**2 + y**2) < $radius**2 ) )"
    set sel [atomselect top "$sel_text"]
    $sel writepdb $cnf_name.removed.pdb
    mol delete all
    mol load pdb $cnf_name.removed.pdb
    set first [llength [ [atomselect top "not $solv_selection"] get resname] ]
    foreach resid [[atomselect top "$solv_selection" ] get resid ] {
	set residue [atomselect top "resname SOLV and resid $resid"]
	$residue set resid [expr $resid + $first]
    }  
    set all [atomselect top all]
    $all writepdb  $cnf_name.removed.pdb
}

#
main
exit
