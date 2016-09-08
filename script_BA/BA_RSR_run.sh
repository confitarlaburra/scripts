#!/bin/bash
#output of BA_RSR.tcl  
OUTNAME=RMSD_RGYR_SASA.dat
DIRECTORY=BA_RMSD_RGYR_SASA
vmd -dispdev text -e ../ana_scripts/BA_RSR.tcl > BA_RSR_VMD.out
# Get averages and errors with tcf
tcf @files $OUTNAME @distribution 2 3 4  > statsBA_RRS.dat

if [ ! -d "$DIRECTORY" ]; then
    mkdir $DIRECTORY 
fi
mv $OUTNAME BA_RSR_VMD.out statsBA_RRS.dat  $DIRECTORY


