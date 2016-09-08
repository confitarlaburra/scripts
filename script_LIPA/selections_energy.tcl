
set all [atomselect top all]

set sugar [atomselect top "resname LIPA and name C1 O1 C2 N2 C3 O3 C4 O4 P4 OP41 OP42 OP43 C5 O5 C6 O6 C7 O7 P7 OP71 OP72 OP73 C8 N8 C9 O9 C10 O11 O10 C11 C12 O12 H1 H2 HN2 H3 H4 HP41 H5 H62 H61 HO6 H7 HP71 H8 HN8 H9 H10 HO10 H11 H121 H122"]

set tails [atomselect top "resname LIPA and not (name C1 O1 C2 N2 C3 O3 C4 O4 P4 OP41 OP42 OP43 C5 O5 C6 O6 C7 O7 P7 OP71 OP72 OP73 C8 N8 C9 O9 C10 O11 O10 C11 C12 O12 H1 H2 HN2 H3 H4 HP41 H5 H62 H61 HO6 H7 HP71 H8 HN8 H9 H10 HO10 H11 H121 H122)"] 

set water [atomselect top water]

set octane [atomselect top "protein"]

$all set beta 0

$sugar set beta 1
$water set beta 2

$all writepdb sugar_water.pdb

$all set beta 0

$sugar set beta 1
$octane set beta 2

$all writepdb sugar_protein.pdb


$all set beta 0

$tails set beta 1
$water set beta 2

$all writepdb water_tails.pdb


$all set beta 0

$tails set beta 1
$octane set beta 2

$all writepdb protein_tails.pdb

$all set beta 0
set lipa [atomselect top "resname LIPA"]
set all [atomselect top all]

$all set beta 2
$lipa set beta 1
$all writepdb lipidA_all.pdb

