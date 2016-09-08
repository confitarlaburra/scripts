#!/usr/bin/perl

BEGIN {
 unshift @INC,"/home/jgarate/bin/perl_modules"
	
}
use Cwd;
use File::chdir;


$gathered = 1;
$base_name ="../gather/gathered_1.trc.gz";
$atoms_count= "s:OW";
$pore_atoms = "1:res(CCC:a)";
$pbc = "v";
$ref = "equilibration/eq_CNT_SPC_5.cnf";
$topo = "7.7_3nm.top";
$radius = "0.45";
$nsim = 1; #for the freze MDS
$count = 1;
$threads =1;

$wd = getcwd;
$dir='pore_loading';
if (-d $dir)
{} else {
	system("mkdir", $dir);
}



## MAIN ##

open (PL, ">$dir/pore_loading.arg");
print PL "\@topo ../$topo\n\@pore $pore_atoms\n\@atoms $atoms_count\n\@ref ../$ref\n\@pbc $pbc\n\@radius $radius\n\@threads $threads\n";
print PL "\@traj\n";
			


while ($count <= $nsim) {
    if ($gathered) {
	print PL  "${base_name}\n";
	$count++;
    } else {
	print PL  "${base_name}_${count}.trc.gz\n";
	$count++;
    }
}






close PL;
$CWD = $dir;
$a = getcwd;
print "Counting.....\n";
system("pore_loading \@f pore_loading.arg &");
$CWD = $wd;




