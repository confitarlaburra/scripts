#!/bin/csh 
#


foreach x (0.0  0.1  0.2  0.3  0.4  0.5  0.6  0.7  0.8  0.9  1.0)

	echo L_$x
  cd L_$x
tser @f tser.inp > dihed.dat
perl /home/jgarate/script/change_to_0_360.pl dihed.dat > dihed_correct.dat
/home/jgarate/script/histogram dihed_correct.dat 90 0 360 > hist_dihedral.dat
	cd ..
end






exit
