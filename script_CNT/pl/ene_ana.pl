#!/usr/bin/perli
use Cwd;
use File::chdir;
$static_base_name = 1;
$base_name ="water_0";
$ene_lib="../../ene_ana.md++.lib";
$nsim = 100; #for the freze MDS
$count = 2;
$wd = getcwd;
$dir = 'ene_ana';
if (-d $dir)
{} else {
	system("mkdir", $dir);
}
open (ENE, ">ene_ana/ene_ana.inp");
print ENE "\@en_files\n";
			
while ($count <= $nsim) {
	if ($static_base_name == 1) {print ENE  "../${base_name}_${count}.tre.gz\n"}
	else {
		if ($count <10) {print ENE  "../${base_name}_1000${count}.tre.gz\n"}
		if ($count >= 10 && $count <100) {print ENE  "../${base_name}_100${count}.tre.gz\n"}
		if ($count >= 100 && $count <1000) {print ENE  "../${base_name}_10${count}.tre.gz\n"}
		if ($count >= 1000 && $count <10000) {print ENE  "../${base_name}_1${count}.tre.gz\n"}
	}
	$count++;
}

#print ENE "\@prop  totene totkin totpot totnonbonded totlj totbond totangle totdihedral totimproper totcov totconstraint totcrf totspecial totdisres eNBP eNBWT eNBWTA eNBCNT eNBCNT-CNT eVDw-CNT-WT eVDw-CNT-WT-NOPT\n";

print ENE "\@prop  totene totkin totpot totnonbonded totlj totbond totangle totdihedral totimproper totcov totconstraint totcrf totspecial totdisres  totangle totimproper irtemp1 mttemp1 boxvol\n";


print ENE "\@library  ${ene_lib}";
close ENE;
$CWD = "$wd/$dir";
system("ene_ana \@f ene_ana.inp > ene_ana.out");
$CWD = $wd;
