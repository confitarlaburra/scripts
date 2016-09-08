#!/bin/bash
#output of BAtopo_desc.tcl
OUTNAME=topo.dat
DIRECTORY=BAtopo
vmd -dispdev text -e ../ana_scripts/BAtopo_desc.tcl > BAtopoVMD.out
# Get averages and errors with tcf
tcf @files $OUTNAME @distribution 2 3 4 5 6 7 > statsBATopo.dat

if [ ! -d "$DIRECTORY" ]; then
    mkdir $DIRECTORY 
fi
mv $OUTNAME BAtopoVMD.out statsBATopo.dat $DIRECTORY


