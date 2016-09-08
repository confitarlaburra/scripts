set offset 1;
foreach index [[atomselect top "resname H2O"] get index] {
 puts "$index"	
 set atom [atomselect top "index $index"]
 $atom set resid [exp [$atom get resid] + $offset]
}
