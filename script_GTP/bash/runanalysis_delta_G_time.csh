#!/bin/csh 
#
set lstart = 1
set lend = 2
set name = md_GTP-BR_LE_0.001_4
set cat_command "cat"
while ( $lstart <= $lend )

	echo Delta_$lstart
	mkdir Delta_$lstart
	mkdir potentials_in_time
	gunzip {$name}_{$lstart}.trs.gz
	cd Delta_$lstart
	/usr/bin/perl  /home/jgarate/Gromos_Files/LE_potentialsv2_G_in_time_v3.pl ../{$name}_{$lstart}.trs 500000
	#gzip ../{$name}_{$lstart}.trs
	wait 
	@ lstart++
	mv ../*trs*.dat ../potentials_in_time
	cd ..
end
set lstart = 1
while ( $lstart <= $lend )
	#$cat_command = "$cat_command Delta_$lstart/Delta_G_ts.dat "
	gzip {$name}_{$lstart}.trs
	@ lstart++	
	
end


#echo $cat_command

exit
