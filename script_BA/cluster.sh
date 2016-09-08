#!/bin/bash
#use it after catdcd_filt.sh and rmsf.sh
#in ana_scripts directory

DNAME='filtered'
CWD=$PWD
SolVCutoff=3.5
CATDCD='/usr/local/lib/vmd_1.91/plugins/LINUXAMD64/bin/catdcd4.0/catdcd'

for i in   CDCA_ch colanic_ch iCDCA_ch iUDCA_ch UDCA_ch
do	
    echo $i
    cd ../$i
    $CATDCD -stride 2 -o $i.2steps.dcd  *dcd
    pwd
    cd   $i$DNAME
    pwd
    for k in 0.10 0.15 0.20 0.25 0.30
    do
	echo $k
	cluster @rmsdmat rmsd_matx.dat  @cutoff $k @time 0 1 @human @precision 4 > cluster.dat
	wait
	if [ -f rmsd_hist.dat ]; then
	    tcf @files rmsd_hist.dat @distribution 1 @normalize @bounds 0 3.5 100 > hist.dat
	    wait
	#    rm rmsd_hist.dat
	fi

	    #if [  -d "cluster$k" ]; then
	    # 	rm -r cluster$k 
	    #fi

	if [ ! -d "cluster$k" ]; then
	    mkdir cluster$k
	fi
	
	vmd -dispdev text -e ../../ana_scripts/write_CLUST.tcl -args ../$i.box.ion.psf ../$i.box.ion.pdb ../$i.2steps.dcd cluster_structures.dat ../../ana_scripts/bigdcd.tcl $SolVCutoff
	#mv cluster*dat  0*pdb  cluster$k
	mv cluster*dat  0*.pdb cluster$k
    done
    cd $CWD
done
