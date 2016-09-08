#!/usr/bin/perli
use Cwd;
use File::chdir;
$static_base_name = 1;
$base_name ="6_6_1";
$topo="../SPC.1.6.6.13.inf.solv.top";

$nsim =100; #for the freze MDS
$nwaters=1;


### MAIN ###

$count_traj = 1;
$count_waters=1;

$wd = getcwd;
$dir = 'tser_dipoles';

if (-d $dir)
{} else {
	system("mkdir", $dir);
}
			
while ($count_waters <= $nwaters) {
	open ($count_waters, ">$dir/$count_waters.inp");
	print $count_waters "\@prop expr\%dot( cart(0,0,1),atom($count_waters:1;va(cog,$count_waters:2,3)))/abs(atom($count_waters:1;va(cog,$count_waters:2,3)))\n";
	print $count_waters "\@pbc r\n"; 
	print $count_waters "\@topo ../$topo\n";
	print $count_waters "\@traj\n";
	$count_traj = 1;	
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
	
	system("tser \@f $count_waters.inp > $count_waters.out");
	$CWD = $wd;
	 $count_waters++;
}

