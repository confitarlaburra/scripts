#!/bin/csh 
#


foreach x (0.0  0.1  0.2  0.3  0.4  0.5  0.6  0.7  0.8  0.9  1.0)

	echo L_$x
  cd L_$x
ene_ana @f ene_ana.inp > ene_ana.out
	cd ..
end






exit
