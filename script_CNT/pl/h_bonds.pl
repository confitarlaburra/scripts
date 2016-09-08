#!/usr/bin/perl
use Cwd;
use File::chdir;

$static_base_name = 1;
$base_name ="water_2";
$DonorAtomsA    = "2-3:HW?";
$AcceptorAtomsB = "2-3:OW";
$pbc = "r";
$topo = "../CNT.5.5.3nm.infinite.13.SPC.top.2.top";
$nsim = 100; #for the freze MDS
$count = 1;
$wd = getcwd;
$dir = 'h_bonds';

if (-d $dir)
{} else {
        system("mkdir", $dir);
}

## MAIN ##

open (PL, ">$dir/h_bonds.arg");
print PL "\@topo $topo\n\@DonorAtomsA $DonorAtomsA\n\@AcceptorAtomsB $AcceptorAtomsB\n\@pbc $pbc\n";
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
system("hbond \@f h_bonds.arg > hbonds.out");
$CWD = $wd;
