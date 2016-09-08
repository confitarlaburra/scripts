#!/usr/bin/perl
use Cwd;
use File::chdir;

$static_base_name = 1;
$base_name ="6.6_3nm_26CCl4";
$pbc = "v";
$topo = "6.6_3nm_26CCL4_water.top";

$nsim = "10";
$count = 1;
$wd = getcwd;
$dir = 'frameout';

if (-d $dir)
{} else {
	system("mkdir", $dir);
}

## MAIN ##

open (PL, ">$dir/frameout.arg");
print PL "\@topo ../$topo\n";
print PL "\@pbc $pbc\n";
print PL "\@single\n";
print PL "\@include ALL\n";
print PL "\@outformat pdb\n";

print PL "\@traj\n";
			
while ($count <= $nsim) {
	print PL  "../${base_name}_${count}.trc.gz\n";	
	$count++;		
}




close PL;
$CWD = $dir;
system("frameout \@f frameout.arg ");
$CWD = $wd;
