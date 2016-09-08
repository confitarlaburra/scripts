#!/usr/bin/perl

BEGIN {
 unshift @INC,"/home/jgarate/bin/perl_modules"
	
}
use Cwd;
use File::chdir;

#use virtual atom (com)
$va=1;
$first_mol = 4569;
$last_mol  = 4594;
#else
$atoms="a:Oeth";
$static_base_name = 1;
$base_name ="gather/gathered";
$pore_atoms = "1:a";
$pbc = "v";
$ref = "equilibration/6.6_3nm_26CH3OH_water_min.cnf";
$topo = "6.6_H2O_26_CH3OH.top";
$radius = "0.38";
$nsim = 1; #for the freze MDS
$count = 1;
$offset = 0.6;
$first = 30000;
$last = 50000;
$threads= 4;
$width =0.0;
$MolAxialLength =0.359;
$bins = 30;
$axialOff = 0.0;


$argName = "pore_rates.arg";
$programName = "pore_rates";
$outName ="taus.out";

$wd =getcwd;
$dir  = "pore_taus";
if (-d $dir)
{} else {
	system("mkdir", $dir);
}



## MAIN ##

open (PL, ">$dir/$argName");
print PL "\@topo ../$topo
\@pore $pore_atoms
\@ref ../$ref
\@pbc $pbc
\@radius $radius
\@first $first
\@last $last
\@threads $threads
\@width $width
\@MolAxialLength $MolAxialLength
\@bins $bins
\@axialOff $axialOff
\@offset $offset\n";
print PL "\@atoms ";
if ($va) {
    while ($first_mol <= $last_mol) {
	if ($first_mol < $last_mol) {print PL  "va(com,$first_mol:a);";}
	if ($first_mol == $last_mol) {print PL  "va(com,$first_mol:a)\n";}
	$first_mol++;
    }		
} else {
    print PL "@atoms $atoms\n";
}
print PL "\@traj\n";
while ($count <= $nsim) {
	print PL  "../${base_name}_${count}.trc.gz\n";	
	$count++;		
}
close PL;

#change to pore_ads directory
$CWD = $dir;
system("$programName \@f $argName > $outName");
$CWD = $wd;
print "program finished!!";
