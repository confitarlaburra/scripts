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
$threads= 4;

#SIM Parameters
$nsim = 2; #for the freze MDS
$count = 1;
$static_base_name = 1;
$argName = "pore_loading.arg";
$programName = "pore_loading";
$outName ="pore_loading.out";
$wd =getcwd;
$dir  = "pore_loading";
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
\@radius $pore_radius
\@threads $threads
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
print "program finished!!\n";
