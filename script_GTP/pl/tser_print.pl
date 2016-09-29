#!/usr/bin/perl

#### Main#####
$lstart = 1;
$ldelta = 1;
$lend   = 20;
$base_name = "../md_GTP-BR_LE_0.001_4_";
$topo = "/home/jgarate/Gromos_Files/MD_files/GTP-BR+3NA.top";
open (OUT, ">tser.inp");
print OUT "\@topo $topo\n";
print OUT "\@pbc r cog\n";
print OUT "\@traj\n";
while ($lstart <= $lend+1e-8) {
	$name = "${base_name}${lstart}.trc.gz";	
	print OUT "$name\n";
	$lstart= $lstart + $ldelta;
	
}
print OUT "\@prop\n tp%1:C4,N9,C1*,O4*";
close OUT;
