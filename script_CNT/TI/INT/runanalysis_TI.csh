#!/bin/bash

ENE_ANA=/home/fett/work/script/script_CNT/TI/INT/makeanalysis_TI.py
TI_SPE=/home/fett/work/script/script_CNT/TI/INT/TI_out_spe.pl
TI_TOT=/home/fett/work/script/script_CNT/TI/INT/TI_out_tot.pl
TI_POT=/home/fett/work/script/script_CNT/TI/INT/TI_out_pot.pl

#Run the ene_ana analysis for the TI calculation (special TI)


python2.7 $ENE_ANA
echo "SPE :"
perl $TI_SPE
echo "POT :"
perl $TI_POT
echo "TOT :"
perl $TI_TOT




