#!/bin/csh 
#


foreach x (0.0  0.1  0.2  0.3  0.4  0.5  0.6  0.7  0.8  0.9  1.0)

	echo LE_TI_LC_$x
  cd LE_TI_LC_$x
	ene_ana @f ene_ana.inp > ene_ana.out
	perl /home/jgarate/Gromos_Files/unbias.pl dvdl.dat ene_ana/totspecial.dat > dvdl_unbias.dat
	cd ..
end






exit
