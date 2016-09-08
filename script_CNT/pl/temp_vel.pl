#!/usr/bin/perli
use Cwd;
use File::chdir;
$static_base_name = 1;
$base_name ="water_1_10fs";
$topo="CNT.5.5.3nm.infinite.13.SPC.top.1.top";
$NDOF="3";
$atoms="2:OW";
$nsim = 1; #for the freze MDS
$count = 1;
$wd = getcwd;
$dir = 'temp_vel';

###MAIN####

if (-d $dir)
{} else {
	system("mkdir", $dir);
}
open (TMP, ">$dir/temp_vel.inp");
print TMP "\@traj\n";
			
while ($count <= $nsim) {
	if ($static_base_name == 1) {print TMP  "../${base_name}_${count}.trv.gz\n"}
	else {
		if ($count <10) {print TMP  "../${base_name}_1000${count}.cnf\n"}
		if ($count >= 10 && $count <100) {print TMP  "../${base_name}_100${count}.cnf\n"}
		if ($count >= 100 && $count <1000) {print TMP  "../${base_name}_10${count}.cnf\n"}
		if ($count >= 1000 && $count <10000) {print TMP  "../${base_name}_1${count}.cnf\n"}
	}
	$count++;
}

print TMP "\@topo ../$topo\n"; 
print TMP"\@NDOF $NDOF\n";
print TMP"\@atoms $atoms\n";


close TMP;
$CWD = "$wd/$dir";
system("/storage/gromos++/x86_64/contrib/temperature \@f temp_vel.inp > temp_vel.out");
$CWD = $wd;
