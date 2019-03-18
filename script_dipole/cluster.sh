#!/bin/bash
#use it after catdcd_filt.sh and rmsf.sh
#in ANA directory

CWD=$PWD
SolVCutoff=0.0
WRITECLUST="/home/jgarate/dipole/ANALYSIS/write_CLUST.tcl"
DCD=full.10.dcd
BIGDCD="/home/jgarate/HV1/MODELS_Ci-HV1_paperCG/ANA/bigdcd.tcl"
MIN=0.0
MAX=8.0
BINS=100
for i in 1.000 
do	
    echo "MODEL $i"
    for j in 0 120 15 165 30 60 90 105 135 150 180 45 75
    do
	echo "MUTANT $j"
	for k in 1
	do
	    echo "Simulation $k"
	    if [ $j != WT ]; then
		#cd ../12AM/$i/$j/out/filtered
		cd ../12A_one_atom_restrained_1dip/$i/$j/out/filtered
		NAME=No.TIP3 
	    else
		cd ../MD/MODEL$i/$j/MD$k/ANA/
		NAME=HV1.POPC.Wat.box.ion.Model$i
	    fi
	    if [ -f rmsd_hist.dat ]; then
		tcf @files rmsd_hist.dat @distribution 1 @normalize @bounds $MIN $MAX $BINS > RMSDhist.dat
		wait
		rm rmsd_hist.dat
	    fi
	    for h in 0.05 0.1 0.15 0.20   
	    do
		echo "CUTOFF $h"
		cluster @rmsdmat rmsd_matx.dat  @cutoff $h @time 0 10 @human @precision 4 > cluster.dat
		wait
		
		if [ ! -d "cluster$h" ]; then
		    mkdir cluster$h
		fi
	
		vmd -dispdev text -e $WRITECLUST -args $NAME.pdb $NAME.pdb $DCD cluster_structures.dat $BIGDCD  $SolVCutoff > vmd_clust.out
		mv cluster*dat  0*.pdb vmd_clust.out  cluster$h
	    done
	    cd $CWD
	done
    done
done
