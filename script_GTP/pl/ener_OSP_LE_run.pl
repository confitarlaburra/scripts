#!/usr/bin/perl

use File::chdir; #provides $CWD variable for manipulating working directory


$lstart = 1; # 1st MD for the LE build MD
$ldelta = 1;
$lend   = 10; # last MD for the LE build MD
$base_name ="GTP-Br-OSP-LE_freeze";
$directory_name ="/home/jgarate/GTP/topo/OSP/"; # super directory fo LE freeze runs
$topology ="/home/jgarate/Gromos_Files/MD_files/GTP+3NA.top";
$nsim = 6; #for the freze MDS
$soft = 0; # 0 no ref state 1 ref state
$state = "GTP";

##Main#####


while ($lstart <= $lend+1e-8) {
        $dir = "${directory_name}frozen_${lstart}";
	if (-d "$dir") {
		$dir_ener  = "${dir}/ener";

		system("mkdir", "$dir_ener");
		if (!$soft) {open (OUT, ">$dir_ener/$base_name.$state.ener.arg");}
		if ($soft)  {open (OUT, ">$dir_ener/$base_name.$state.soft.ener.arg");}
		print OUT "\@atoms 1:14,15\n";
		print OUT "\@topo $topology\n";
		print OUT "\@pbc r\n";
		print 	OUT "\@eps 61\n";
		print OUT "\@kap 0.0\n";
		print OUT "\@time    0 0.2\n";
		print OUT "\@RFex on\n";
		if ($soft) {		
			print OUT "\@soft 1:15\n";
			print OUT "\@softpar 0.7 1.0 1.0\n";
		}  		
		print OUT "\@traj \n";
		for ($i =1; $i <= $nsim; $i++) {
			print OUT "..\/${base_name}_${lstart}_$i.trc.gz\n";		
		}
		close OUT;
		if (!$soft) {
			print "Calculating for $state $dir .....\n";
			local $CWD = "$dir_ener";
		 	system "ener \@f $base_name.$state.ener.arg > ${state}.osp.ener.dat";
		 	local $CWD = $directory_name;
		}
		
		if ($soft) {
			print "Calculating for  $state $dir (soft).....\n";
			local $CWD = "$dir_ener";
		 	system "ener \@f $base_name.$state.soft.ener.arg > ${state}.osp.ener.soft.dat";
		 	local $CWD = $directory_name;
		}				
			  
			 
        } #else {print "Directory $dir does not exists\n";}
	
	$lstart += $ldelta;
}

