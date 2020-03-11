#!/bin/bash
#use it after catdcd_filt.sh and rmsf.sh
#in ANA directory

CWD=$PWD
SolVCutoff=100
WRITECLUST="/home/jgarate/opt/scripts/script_dipole/write_CLUST.tcl"
DCD=filt.10.dcd
BIGDCD="/home/jgarate/opt/scripts/script_dipole/bigdcd.tcl"
MIN=0.0
MAX=8.0
BINS=500
VMD=/opt/vmd-1.9.3/bin/vmd-1.9.3
module load  gromos++/1.41-openmp
for i in 1.000 
do	
    echo "MODEL $i"
    for j in 0 
    do
	echo "MUTANT $j"
	for k in 1
	do
	    echo "Simulation $k"
	    if [ $j != WT ]; then
		#cd ../12AM/$i/$j/out/filtered
		cd ../../../work/TRPV1/MD/MD1/filtered/
		NAME=No.CLA
	    else
		cd ../MD/MODEL$i/$j/MD$k/ANA/
		NAME=HV1.POPC.Wat.box.ion.Model$i
	    fi
	    if [ -f rmsd_hist.dat ]; then
		tcf @files rmsd_hist.dat @distribution 1 @normalize @bounds $MIN $MAX $BINS > RMSDhist.dat
		wait
		rm rmsd_hist.dat
	    fi
	    for h in  0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.60  
	    do
		echo "CUTOFF $h"
		cluster @rmsdmat rmsd_matx.dat  @cutoff $h @time 0 10 @human @precision 4 > cluster.dat
		wait
		
		if [ ! -d "cluster$h" ]; then
		    mkdir cluster$h
		fi
	
		$VMD -dispdev text -e $WRITECLUST -args $NAME.pdb $NAME.pdb $DCD cluster_structures.dat $BIGDCD  $SolVCutoff > vmd_clust.out
		mv cluster*dat  0*.pdb vmd_clust.out  cluster$h
	    done
	    cd $CWD
	done
    done
done
