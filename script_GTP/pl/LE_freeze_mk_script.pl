#!/usr/bin/perl
# LE freeze MD files generation #
#use relative paths#
#run it inside the LE simulation#
#### Main#####
$lstart = 1; # 1st MD for the LE build MD
$ldelta = 1;
$lend   = 10; # last MD for the LE build MD
$base_name ="LE_TI_0.5";
$directory_name ="/home/jgarate/GTP/topo/TI/LE/L_0.5/Build_LE"; # super directory fo LE freeze runs
$nsim = 3; #for the freze MDS
#Paths to input files and binaries (must change every time)

###this must be relative paths
$topology ="../../../../../../Gromos_Files/MD_files/GTP+3NA.top";
$topology="../${topology}";
$led = "../../../../../../Gromos_Files/MD_files/GTP.led";
$led ="../${led}";
$lud = "../../../../../../Gromos_Files/MD_files/GTP.lud";
$lud ="../${lud}";
#### This can be absolute paths (recommended)
$imd = "/home/jgarate/Gromos_Files/MD_files/md_LE_freeze.imd";
$md_lib ="/home/jgarate/Gromos_Files/MD_files/mk_script_mpi.lib";
$ene_lib="/home/jgarate/Gromos_Files/MD_files/ene_ana.md++.lib";

$bin = "/share/apps/prog/gromosXX_mpi/md_mpi";


##Main#####
#Run,  chs script ti submit jobs#
open (RUN, ">run_froze.csh");
#write files
print RUN "\#!/bin/csh/\n\#\n\n\nforeach x (";
$csh_bool = 0;
for ($j = $lstart; $j <= $lend; $j++) { print RUN "$j "};
while ($lstart <= $lend+1e-8) {
	$count =1;
        $coord = "../${base_name}_${lstart}.cnf"; 
	$dir   = "frozen_${lstart}";
        $directory = "${directory_name}/${dir}";
        $dir_tser    = "${dir}/tser";
	$dir_ene_ana = "${dir}/ene_ana";
        system("mkdir", "$dir");
 	system("mkdir", "$dir_tser");
        system("mkdir", "$dir_ene_ana");
	open (MD, ">$dir/md_mk.arg");
	print MD "\@sys   ${base_name}_freeze_${lstart}\n";
        print MD "\@bin $bin\n";
	print MD "\@dir   $directory\n";
        print MD "\@files\n";
        print MD "topo $topology\ninput $imd\ncoord $coord\nledih $led\nleumb $lud\n";
        print MD "\@template $md_lib\n";
        print MD "\@version md++\n";
        print MD "\@script 1 $nsim";     
	close MD;
        open (TSER, ">$dir_tser/tser.arg");
	print TSER "\@topo ../${topology}\n\@pbc r cog\n";
	print TSER "\@traj\n";
	open (ENE, ">$dir_ene_ana/ene_ana.arg");
	print ENE "\@en_files\n";		
	while ($count <= $nsim) {
		print TSER "../${base_name}_freeze_${lstart}_${count}.trc.gz\n";
		print ENE "../${base_name}_freeze_${lstart}_${count}.tre.gz\n";
		$count++;
 	}
	print TSER "\@prop\ntp\%1:C4,N9,C1*,O4*";
	print ENE "\@prop     totspecial\n";
	print ENE "\@topo ../${topology}\n";
	print ENE "\@library  ${ene_lib}";
	close ENE;
	close TSER;
	close MD;
	$argument = "\@f ${dir}/md_mk.arg";
        $argument_2 = "${base_name}_freeze_${lstart}_1.run.sh"; 
	system ("mk_script $argument");
	if ($csh_bool == 0) { 
		print RUN ")\n   echo frozen_\$x \n cd frozen_\$x\n/home/oostenbrink/programs/bin/submit *1.run plain 4\n";
i	}
        $lstart = $lstart+$ldelta;
	$csh_bool = 1;
}

print RUN "cd ..\n end\n exit";

close RUN;
