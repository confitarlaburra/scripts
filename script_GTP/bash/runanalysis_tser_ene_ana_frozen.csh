#!/bin/csh 
#
set lstart = 11
set lend = 11
set name = md_GTP-BR_LE_0.001_4_freeze
while ( $lstart <= $lend )
	echo Frozen MD directory frozen_$lstart
	cd frozen_{$lstart}
	gunzip {$name}_{$lstart}_1.trs.gz
	echo Calculating pmf and bias Delta g
	/usr/bin/perl  /home/jgarate/Gromos_Files/LE_potentialsv2_G_in_time_v3.pl {$name}_{$lstart}_1.trs 500000 > out.dat
	/usr/bin/perl  /home/jgarate/Gromos_Files/Delta_G_pmf.pl      {$name}_{$lstart}_1.trs.999.80.dat > Delta_PMF.dat
	/usr/bin/perl  /home/jgarate/Gromos_Files/Delta_G_syn_anti.pl {$name}_{$lstart}_1.trs.999.80.dat > Delta_syn_anti.dat
	cd tser
		echo Calculating Dihedral time-series, transitions and Bias Delta G 		
		tser @f tser.arg > dihed.dat
		/usr/bin/perl /home/jgarate/Gromos_Files/change_to_0_360.pl dihed.dat   > dihed_correc.dat
		/usr/bin/perl /home/jgarate/Gromos_Files/Total_transitions_strict.pl    > total_transitions.dat
		/usr/bin/perl /home/jgarate/Gromos_Files/Syn_anti_G.pl dihed_correc.dat > Syn_anti_G.dat
	cd ../ene_ana/
		echo Calculating LE energy and final Delta G values
        	ene_ana @f ene_ana.arg > ene_ana.dat
		/usr/bin/perl /home/jgarate/Gromos_Files/delete_first_line.pl totspecial.dat
		/usr/bin/perl /home/jgarate/Gromos_Files/dihed_energy_plot.pl ../tser/dihed_correc.dat totspecial_1line.dat > totdihed.dat
		/usr/bin/perl /home/jgarate/Gromos_Files/Delta_G_LEUS.pl totdihed.dat > LEUS.dat
		/usr/bin/perl /home/jgarate/Gromos_Files/Delta_G_syn_anti.pl  totdihed.dat > Perturb.dat
	@ lstart++
	cd ..
	cd ..

end
	
exit
