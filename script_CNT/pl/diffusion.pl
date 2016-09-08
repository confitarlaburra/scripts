#!/usr/bin/perl
BEGIN {
 unshift @INC,"/home/jgarate/bin/perl_modules"

}
use Cwd;
use File::chdir;


$static_base_name = 1;
$base_name ="ethOH_26";
$atoms    = "a:Oeth";
$pbc = "r";
$topo = "../CH3CH2OH_22.top";
$nsim = 9; #for the freze MDS
$count = 1;
$wd = getcwd;
$dir = 'diffusion';
$time ="0.0 0.5";
$set_time="0";
if (-d $dir)
{} else {
        system("mkdir", $dir);
}

## MAIN ##

open (PL, ">$dir/diffus.arg");
print PL "\@topo ../$topo\n\@atoms $atoms\n\@pbc $pbc\n";
if ($set_time) {
	print PL "\@time $time\n";
}
print PL "\@traj\n";
			
	
while ($count <= $nsim) {
        if ($static_base_name == 1) {print PL  "../${base_name}_${count}.trc.gz\n"}
        else {
                if ($count <10) {print PL  "../${base_name}_1000${count}.trc.gz\n"}
                if ($count >= 10 && $count <100) {print PL  "../${base_name}_100${count}.trc.gz\n"}
                if ($count >= 100 && $count <1000) {print PL  "../${base_name}_10${count}.trc.gz\n"}
                if ($count >= 1000 && $count <10000) {print PL  "../${base_name}_1${count}.trc.gz\n"}
        }
        $count++;
}




close PL;
$CWD = "$wd/$dir";
system("diffus \@f diffus.arg > diff.out");
$CWD = $wd;
