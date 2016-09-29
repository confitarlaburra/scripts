#!/usr/bin/perl
# Performs analysis of GTP frozen MDs#
#use relative paths#
#run it inside the frozen simulation directory#
#### Main#####
#Paths to input files and binaries (must change every time)
$topology ="/home/jgarate/Gromos_Files/MD_files/GTP-BR+3NA.top";
$base_name ="TI_GTP-GTP-BR_build_LE_0.3";
$ene_lib="/home/jgarate/Gromos_Files/MD_files/ene_ana.md++.lib";
$directory_name ="/storage/GTP/topo/TI/TI_long/forward/LE_TI_LC_0.3";
$nsim = 3; #for the freze MDS
open (RUN, ">run_froze.csh");
print RUN "\#!/bin/csh/\n\#\n\n\n";
print RUN "echo unbinning LE potential....\n";
print RUN "gunzip ${base_name}_1.trs.gz\n";
print RUN "/usr/bin/perl  /home/jgarate/Gromos_Files/LE_potentialsv2_G_in_time_v3.pl {$base_name}_1.trs 500000 > out.dat\n";
print RUN "/usr/bin/perl  /home/jgarate/Gromos_Files/Delta_G_pmf.pl  *80.dat > Delta_PMF.dat\n";
print RUN"/usr/bin/perl  /home/jgarate/Gromos_Files/Delta_G_syn_anti.pl *80.dat > Delta_syn_anti.dat\n";
print RUN "cd tser\necho Calculating Dihedral time-series, transitions and Bias Delta G....\n";
print RUN "tser \@f tser.arg > dihed.dat\n";
print RUN "/usr/bin/perl /home/jgarate/Gromos_Files/change_to_0_360.pl dihed.dat   > dihed_correc.dat\n";
print RUN "/usr/bin/perl /home/jgarate/Gromos_Files/Total_transitions_strict.pl dihed_correc.dat   > total_transitions.dat\n";
print RUN "/usr/bin/perl /home/jgarate/Gromos_Files/Total_transitions_strict.pl dihed_correc.dat 5000   > total_transitions.5000.dat\n";
print RUN "/home/jgarate/Gromos_Files/histogram dihed_correc.dat 90 0 360 > histo.dat\n";
print RUN "/usr/bin/perl /home/jgarate/Gromos_Files/Syn_anti_G.pl dihed_correc.dat > Syn_anti_G.dat\n";
print RUN "cd ..\necho Calculating LE energy and final Delta G values....\ncd ene_ana\n";
print RUN "ene_ana \@f ene_ana.arg > ene_ana.dat\n";
print RUN "/usr/bin/perl /home/jgarate/Gromos_Files/delete_first_line.pl totspecial.dat\n";
print RUN "/usr/bin/perl /home/jgarate/Gromos_Files/dihed_energy_plot.pl ../tser/dihed_correc.dat totspecial_1line.dat > totdihed.dat\n";
print RUN "/usr/bin/perl /home/jgarate/Gromos_Files/Delta_G_LEUS.pl totdihed.dat > LEUS.dat\n";
print RUN "/usr/bin/perl /home/jgarate/Gromos_Files/Delta_G_syn_anti.pl  totdihed.dat > Perturb.dat\n";
print RUN "cd ..\n";
print RUN "exit\n";
close RUN;
$dir_tser    = "${directory_name}/tser";
$dir_ene_ana = "${directory_name}/ene_ana";
system("mkdir", "$dir_tser");
system("mkdir", "$dir_ene_ana");
#write files
open (TSER, ">$dir_tser/tser.arg");	
print TSER "\@topo ${topology}\n\@pbc r cog\n";
print TSER "\@traj\n";
open (ENE, ">$dir_ene_ana/ene_ana.arg");
print ENE "\@en_files\n";
$count = 1.0;			
while ($count <= $nsim) {
	print TSER "../${base_name}_${count}.trc.gz\n";
	print ENE  "../${base_name}_${count}.tre.gz\n";
	$count++;
 }
print TSER "\@prop\ntp\%1:C4,N9,C1*,O4*";
print ENE "\@prop     totspecial\n";
print ENE "\@topo     ${topology}\n";
print ENE "\@library  ${ene_lib}";
close ENE;
close TSER;
print "run \"csh run_froze.csh\" to perform analysis\n"; 

