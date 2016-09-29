#!/usr/bin/perl
# TI LE fronzen linear interpolation  runs MD #
#use relative paths#
#run it inside the TI normal   simulation#


## subroutine tha calculates the weighted sum of biases potentials##
# bias one lambda = 0.0
# bias two lambda = 1.0
sub GeneralPotentials {
	$lambda=$_[0]; 
	(@bias_1) = @{$_[1]};
        (@bias_2) = @{$_[2]};
	(@newbias)=();
	$size =@bias_1;
	for ($count = 0; $count  < $size; $count++) {
 		$new = (1-$lambda)*$bias_1[$count] + $lambda*$bias_2[$count];
		#round to the nearest integer
		$new = int($new +0.5);
		$newbias[$count]= $new;
 	}
	return (\@newbias);
}



#### Main#####
$lstart = 0.0; # 1st MD
$ldelta = 0.1;
$lend   = 1.0; # last MD
$base_name ="TI_BR_GTP-GTP"; ### Change it every time 
$directory_name ="/pool/jgarate/GTP/topo/TI/TI_long/backward"; # super directory fo LE freeze runs
$nsim_TI = 6;
$nsim = 6; #for the freze MDS
#Paths to input files and binaries (must change every time)

###these must be relative paths

$topology ="../../../../../../../home/jgarate/Gromos_Files/MD_files/GTP-BR+3NA.top";
$topology="../${topology}";
$led = "../../../../../../../home/jgarate/Gromos_Files/MD_files/GTP.led";
$led ="../${led}";
$lud = "../../../../../../../home/jgarate/Gromos_Files/MD_files/GTP.lud";
$lud ="../${lud}";
$pttop ="../../../../../../../home/jgarate/Gromos_Files/MD_files/GTP_BR.pttop";
$pttop="../${pttop}";
#### These can be absolute paths (recommended)
$imd = "/home/jgarate/Gromos_Files/MD_files/TI_LE_frozen.imd"; #use always this (RLAM 0.5 for regular expresions)
$md_lib ="/home/jgarate/Gromos_Files/MD_files/mk_script_mpi.lib";
$binary = "/share/apps/prog/gromosXX_mpi/md_mpi";
$ene_lib="/home/jgarate/Gromos_Files/MD_files/ene_ana.md++.lib";
# Path to cnfs with optimized potentials#
$CNF_lambda_0= "/home/jgarate/Gromos_Files/MD_files/LE_optimized_runs/md_GTP_LE_0.001_4_frozen_1800.cnf";
$CNF_lambda_1= "/home/jgarate/Gromos_Files/MD_files/LE_optimized_runs/md_GTP-BR_LE_0.001_4_freeze_18_1.cnf";
#$cnf = path to cnf;  # unccoment and define, if no previous TI was run

#############################
#####Get mixed Potentials#######
#############################
open (FILE_0, "$CNF_lambda_0"); # FILE_1 = first  cnf file
open (FILE_1, "$CNF_lambda_1"); # FILE_2 = second cnf file


#Read cnf 1 and get 1st LE potential
while ($line=<FILE_0>) {	
	if ($line=~/NVISLE/) { $counter = 1;}
	if ($counter == 1 && $line=~/\s+(\d+)\s+(\d+)/) {
		$visits_1 = $1;
		$bin = $2;
		#print "$visits_1\n";
		push(@visits_1_array,$visits_1);
		push(@bins,$bin); 
	}
	if ($line=~/END/) { $counter = 0.0;}
}

#Read cnf 2 and get 2nd LE potential
while ($line=<FILE_1>) {	
	if ($line=~/NVISLE/) { $counter = 1;}
	if ($counter== 1 && $line=~/\s+(\d+)\s+(\d+)/) {
		$visits_2 = $1;
		$bin = $2;
		#print "$visits_2\n";
		push(@visits_2_array,$visits_2);
	}
	if ($line=~/END/) { $counter = 0.0;}
}


close FILE_0;
close FILE_1;

##Main#####

open (RUN, ">run_LE_TI_linear.csh");
#write files
print RUN "\#!/bin/csh/\n\#\n\n\nforeach x (";
$csh_bool = 0;
for ($j = $lstart ; $j < $lend; $j = $j + 0.1) { printf RUN ("%.1f ", $j )};
while ($lstart <= $lend+1e-8) {
	
	$lstart = sprintf "%.1f",$lstart; 
	$count =1;
	$jobnumber = int($lstart*10000) + $nsim_TI;
        $coord = "../L_$lstart/${base_name}_${jobnumber}.cnf";
	#$coord = $cnf; # uncomment if no previuous TI was run
	$dir   = "LE_TI_LC_${lstart}";
        $directory = "${directory_name}/${dir}";
	$dir_tser    = "${dir}/tser";
	$dir_ene_ana = "${dir}/ene_ana";
        system("mkdir", "$dir");
 	system("mkdir", "$dir_tser");
        system("mkdir", "$dir_ene_ana");
	##Compute New weighted bias potential##
	($a)= &GeneralPotentials($lstart,\@visits_1_array,\@visits_2_array);
	@newbias = @$a;
	$size = @newbias;
	$newcnf = "${base_name}_${jobnumber}.LC_LE.cnf";
	open (OUT, "> $directory/${base_name}_${jobnumber}.LC_LE.cnf"); #cnf with the LC (linear combination) of both LE potentials 
	open (FILE_3, "L_$lstart/${base_name}_${jobnumber}.cnf"); # FILE_3 = init CNF for simulation
		while ($line=<FILE_3>) {
		print OUT "$line";	
	}	
	open (FILE_1, "$CNF_lambda_1");
		while ($line=<FILE_1>) {	
			if ($line=~/LEUSBIAS/) { $counter = 1; }
			if ($counter == 1) {print OUT $line;}
			if ($line=~/NVISLE /) { $counter = 0.0;}
		}

	for ($count = 0; $count < $size; $count++) {
	 	printf OUT  "%10.d %9.d\n", $newbias[$count], $bins[$count];
	}
	print OUT "END";
	close OUT;
	## Generate imd for each lambda point
	open (IMD, "$imd");
	$name_imd = "${base_name}_LC_LE_${lstart}.imd";
	#print "$name_imd\n";
	open (IMD2, ">LE_TI_LC_${lstart}/$name_imd");
	while ($line=<IMD>) {
		if ($line=~/^PERTURBATION/) { $bool = 1;} 
		if ( ($bool == 1) && ($line =~/^\s+1\s+0\s+0.5\s+0/) ) {$line =~s/^\s+1\s+0\s+0.5\s+0/          1       0       $lstart       0/;} 
		if ($line=~/^END/) { $bool = 0;}
		print IMD2 "$line";
	}	
	close IMD;
	close IMD2;
	
	open (MD, ">$dir/md_mk.arg");
	print MD "\@sys   ${base_name}_LC_LE_${lstart}\n";
        print MD "\@bin $binary\n";
	print MD "\@dir   $directory\n";
        print MD "\@files\n";
        print MD "topo $topology\ninput $name_imd \ncoord $newcnf\nledih $led\nleumb $lud\npttopo $pttop\n";
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
		print TSER "../${base_name}_LC_LE_${lstart}_${count}.trc.gz\n";
		print ENE  "../${base_name}_LC_LE_${lstart}_${count}.tre.gz\n";
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
		print RUN ")\n   echo LE_TI_LC_\$x \n cd LE_TI_LC_\$x\n/home/oostenbrink/programs/bin/submit *1.run plain 4\n";
	}
	#print "$lstart\n";
        $lstart = $lstart+$ldelta;
	$lstart = sprintf "%.1f",$lstart; 
	$csh_bool = 1;
}

print RUN "cd ..\n end\n exit";
close RUN;

