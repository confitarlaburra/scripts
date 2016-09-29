#!/usr/bin/perl
# TI LE build runs MD for GTP #
#run it inside the TI  simulation#



#### Main#####

$lstart = 0.0; # lamba 0
$ldelta = 0.1;
$lend   = 1.0; # lambda 1
$base_name ="TI_GTP-GTP-BR";
$directory_name ="/pool/jgarate/GTP/topo/TI/TI_long/forward"; # super directory fo LE freeze runs
$nsim_TI = 6; # number of TI simulations per each lambda point.
$nsim = 10; # number of simulations fo the build MDS per lambda point
#Paths to input files and binaries (must change every time)

###these must be relative paths
$topology ="../../../../../../../home/jgarate/Gromos_Files/MD_files/GTP+3NA.top";
$topology="../${topology}";
$led = "../../../../../../../home/jgarate/Gromos_Files/MD_files/GTP.led";
$led ="../${led}";
$lud = "../../../../../../../home/jgarate/Gromos_Files/MD_files/GTP.lud";
$lud ="../${lud}";
$pttop ="../../../../../../../home/jgarate/Gromos_Files/MD_files/GTP.pttop";
$pttop="../${pttop}";

#### These can be absolute paths (recommended)
$imd = "/home/jgarate/Gromos_Files/MD_files/TI_LE_build.imd"; #use always this (RLAM 0.5)
$md_lib ="/home/jgarate/Gromos_Files/MD_files/mk_script_mpi.lib";
$bin = "/share/apps/prog/gromosXX_mpi/md_mpi";
$ene_lib="/home/jgarate/Gromos_Files/MD_files/ene_ana.md++.lib";


##Main#####

##Run is a csh script for submitting the jobs afet running this script###
open (RUN, ">run_LE_TI_build.csh");
print RUN "\#!/bin/csh/\n\#\n\n\nforeach x (";
$csh_bool = 0;
##Assuming tha the lambda point 0 and 1 have already been simulated##
for ($j = $lstart + 0.1; $j < $lend - 0.1; $j = $j + 0.1) { print RUN "$j "};

while ($lstart <= $lend+1e-8) {
	
	$lstart = sprintf "%.1f",$lstart; 
	$count =1;
	$jobnumber = int($lstart*10000) + $nsim_TI;
        $coord = "../L_$lstart/${base_name}_${jobnumber}.cnf"; 
	$dir   = "LE_TI_${lstart}";
        $directory = "${directory_name}/${dir}";
	$dir_tser    = "${dir}/tser";
	$dir_ene_ana = "${dir}/ene_ana";
        system("mkdir", "$dir");
 	system("mkdir", "$dir_tser");
        system("mkdir", "$dir_ene_ana");
	# Generate imd for each lambda point (change RLAM from 0.5 to $lstart	
	open (IMD, "$imd");
	$name_imd = "${base_name}_build_LE_${lstart}.imd";
	open (IMD2, ">LE_TI_${lstart}/$name_imd");
	while ($line=<IMD>) {
		if ($line=~/^PERTURBATION/) { $bool = 1;} 
		if ( ($bool == 1) && ($line =~/^\s+1\s+0\s+0.5\s+0/) ) {$line =~s/^\s+1\s+0\s+0.5\s+0/          1       0       $lstart       0/;} 
		if ($line=~/^END/) { $bool = 0;}
		print IMD2 "$line";
	}	
	close IMD;
	close IMD2;
	#### Write input files for mk_scrip and tser#######
	open (MD, ">$dir/md_mk.arg");
	print MD "\@sys   ${base_name}_build_LE_${lstart}\n";
        print MD "\@bin $bin\n";
	print MD "\@dir   $directory\n";
        print MD "\@files\n";
        print MD "topo $topology\ninput $name_imd \ncoord $coord\nledih $led\nleumb $lud\npttopo $pttop\n";
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
		print TSER "../${base_name}_build_LE_${lstart}_${count}.trc.gz\n";
		print ENE  "../${base_name}_build_LE_${lstart}_${count}.tre.gz\n";
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
		print RUN ")\n   echo LE_TI_\$x \n cd LE_TI_\$x\n/home/oostenbrink/programs/bin/submit *1.run plain 4\n";
	}
        $lstart = $lstart+$ldelta;
	$lstart = sprintf "%.1f",$lstart; 
	$csh_bool = 1;
}

print RUN "cd ..\n end\n exit";
close RUN;


### change first  NTLESA from 1 to 2 , first LE run need to read LE from LUD file, rest reads from cnf of previous simulation####
$lstart = 0.0; # 1st MD
$ldelta = 0.1;
$lend   = 1.0; # last MD
while ($lstart <= $lend+1e-8) {
	$lstart = sprintf "%.1f",$lstart;
	open (FILE_1, "LE_TI_${lstart}/${base_name}_build_LE_${lstart}_1.imd");
	open (FILE_2, ">LE_TI_${lstart}/${base_name}_build_LE_${lstart}_1.imd.new");
	while ($line=<FILE_1>) {
		if ($line=~/^LOCALELEV/) { $bool = 1;}
		if ( ($bool == 1) && ($line =~/^\s+1\s+1\s+1\s+100/) ) {$line =~s/^\s+1\s+1\s+1\s+100/          1       1       2     100/;} 
		if ($line=~/^END/) { $bool = 0;}
		print FILE_2 "$line";
	}	
	close FILE_1;
	close FILE_2;
	system ("rm  LE_TI_${lstart}/${base_name}_build_LE_${lstart}_1.imd");
	system ("mv  LE_TI_${lstart}/${base_name}_build_LE_${lstart}_1.imd.new LE_TI_${lstart}/${base_name}_build_LE_${lstart}_1.imd"); 
	$lstart = $lstart+$ldelta;
	$lstart = sprintf "%.1f",$lstart;
}

