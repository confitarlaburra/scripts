#!/usr/bin/perl
BEGIN {
 unshift @INC,"/home/jgarate/bin/perl_modules"

}
use Cwd;
use File::chdir;
$static_base_name = 1;
$base_name ="ethOH_26";
$topo = "../CH3CH2OH_22.top";

$nsim = 9; #for the freze MDS
$nwaters=22;
$average =0;

### MAIN ###

$count_traj_out = 1;
$count_waters=1;

$wd = getcwd;
$dir = 'rot_relax';

if (-d $dir)
{} else {
	system("mkdir", $dir);
}
			
while ($count_waters <= $nwaters) {
	open ($count_waters, ">rot_relax/$count_waters.inp");
	print $count_waters "\@ax1 atom($count_waters:1;va(cog,$count_waters:1,2,3))\n";
	print $count_waters "\@ax2 atom($count_waters:1,3)\n";
	print $count_waters "\@pbc r\n"; 
	print $count_waters "\@topo ../$topo\n";
	if ($average) {
	    print $count_waters "\@average\n";
	}
	print $count_waters "\@traj\n";
	$count_traj = $count_traj_out;	
	while ($count_traj <= $nsim) {
		if ($static_base_name == 1) {print $count_waters  "../${base_name}_${count_traj}.trc.gz\n"}
		else {
			if ($count_traj <10) {print $count_waters  "../${base_name}_1000${count_traj}.trc.gz\n"}
			if ($count_traj >= 10 && $count_traj <100) {print $count_waters  "../${base_name}_100${count_traj}.trc.gz\n"}
			if ($count_traj >= 100 && $count_traj <1000) {print $count_waters  "../${base_name}_10${count_traj}.trc.gz\n"}
			if ($count_traj >= 1000 && $count_traj <10000) {print $count_waters  "../${base_name}_1${count_traj}.trc.gz\n"}
		}
		$count_traj++;
	}

	close $count_waters;
	$CWD = "$wd/$dir";
	
	system("rot_rel \@f $count_waters.inp > $count_waters.out");
	$CWD = $wd;
	 $count_waters++;
}

