#!/usr/bin/perl

BEGIN {
 unshift @INC,"/home/jgarate/bin/perl_modules"

}
use Cwd;
use File::chdir;


$static_base_name = 1;
$base_name ="8.8_3nm_23ETHO";
$topo = "8.8_3nm_23ETOH_solv.top";
$center =208;
$atoms = "a:a;s:a";
$outformat = trc;
$threads = 1;
$nsim = 50;
$count = 1;
$wd = getcwd;
$dir = 'gather';
$outname = "gathered_1.trc";

if (-d $dir)
{} else {
    system("mkdir", $dir);
}

## MAIN ##

open (PL, ">$dir/gather.arg");
print PL "\@topo ../$topo\n";
print PL "\@outformat $outformat\n";
print PL "\@center $center\n";
print PL "\@atoms $atoms\n";
print PL "\@threads $threads\n";
print PL "\@first 0\n";
print PL "\@last 50000\n";
print PL "\@traj\n";
			
while ($count <= $nsim) {
    print PL  "../${base_name}_${count}.trc.gz\n";	
    $count++;		
}




close PL;
$CWD = $dir;
$a = getcwd;
print "Gathering.....\n";
system("gatherNT \@f gather.arg > $outname");
$CWD = $wd;
