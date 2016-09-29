#!/usr/bin/perl

#### Main#####
$lstart = 1;
$ldelta = 1;
$lend   = 10;
$base_name = "../md_GTP-BR_LE_0.004_4_";
$ene_lib= "/home/jgarate/Gromos_Files/MD_files/ene_ana.md++.lib";
$topo = "/home/jgarate/Gromos_Files/MD_files/GTP-BR+3NA.top";
open (OUT, ">ene.inp");
print OUT "\@en_files\n";
while ($lstart <= $lend+1e-8) {
	$name = "${base_name}${lstart}.tre.gz";	
	print OUT "$name\n";
	$lstart= $lstart + $ldelta;
	
}
print OUT "\@prop     totspecial\n";
print OUT "\@library  $ene_lib\n";
#print OUT "\@topology $topo";
close OUT;
