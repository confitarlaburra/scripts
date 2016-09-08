#!/usr/bin/perl

BEGIN {
 unshift @INC,"/home/jgarate/bin/perl_modules"
	
}
use Cwd;
use File::chdir;

#use virtual atom (com)
$va=1;
$first_mol = 4724;
$last_mol  = 4751;
#else
$atoms="a:Oeth";

$base_name ="gather/gathered";

$pore_atoms = "1:a";
$pbc = "v";
$ref = "equilibration/8.8_3nm_28CH3OH_water_min.cnf";
$topo = "8.8_3nm_28CH3OH_water.top";
$pore_radius = "0.505";
$offset = 0.0;
$first = 30000;
$last = 50000;
$threads= 4;
$bins = 7;
$full = 0;


$nsim = 1; #for the freze MDS
$count = 1;
$static_base_name = 1;
$argName = "pore_dist_corr.arg";
$programName = " pore_dist_corr";
$outName ="pore_dist_corr.out";
$wd =getcwd;
$dir  = "dist_corr";

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
\@pore_radius $pore_radius
\@first $first
\@last $last
\@threads $threads
\@offset $offset
\@bins $bins
\@full $full\n";

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
