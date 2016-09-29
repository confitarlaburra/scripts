#!/bin/csh 
#


foreach x (1200  1800  2000  2450  3000  8000 )

	echo frozen_$x
  cd frozen_$x
	cd tser
	echo Total
	/usr/bin/perl /home/jgarate/Gromos_Files/Total_transitions_strict.pl dihed_correct.dat
	echo 1000
	/usr/bin/perl /home/jgarate/Gromos_Files/Total_transitions_strict.pl dihed_correct.dat 1000
	cd ..
	cd ..
end


exit
