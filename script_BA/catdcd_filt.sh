#!/bin/bash

#Script that filters a series of dcd removing all solvent molecules

PDB='.box.ion.pdb'
INDEX_SCRIPT='/home/fett/work/Biliar_acids/2015/ana_scripts/pdb_zero_index.pl'
CATDCD='/usr/local/lib/vmd_1.91/plugins/LINUXAMD64/bin/catdcd4.0/catdcd'
RESNAME='LIG'
DNAME='filtered'
DESTFOLD='/home/fett/Dropbox/bileacid2014/filteredMD'
CWD=pwd

#if [ ! -d "$DIRECTORY" ]; then
#    mkdir $DESTFOLD 
#fi



for i in   UDCA_ch   #3DOXlagoCA 3DOXUCA CA iCA ilagoCA iLCA lagoDCA 3DOXCDCA 3DOXlagoDCA 3DOXUDCA CDCA DCA iCDCA ilagoDCA iUCA lagoUCA UCA 3DOXDCA 3DOXlagoUCA colanic iDCA   ilagoUCA  lagoCA  LCA UDCA
do	
    echo $i
    cd ../$i
    pwd
    perl $INDEX_SCRIPT $i$PDB $RESNAME 
    wait
    mv eq2.* equilibration
    $CATDCD -o $i.dcd  -i index.dat *dcd
    wait
    if [ ! -d "$i$DNAME$j" ]; then
	mkdir $i$DNAME$j 
    fi
    mv $i.dcd index.dat $i$DNAME$j
    cp -r build/$i.psf BAtopo  $i$DNAME$j
	#cp -r $i$DNAME$j $DESTFOLD
    cd $PWD
done
cd $PWD
pwd
