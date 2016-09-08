#!/bin/bash

#Script that filters and concatenates a series of dcd removing all solvent molecules
# based on the structure of 

echo -n  "Enter solvent residue [ENTER]: "
read RESNAME

echo -n  "Enter PDB name [ENTER]:  "
read PDB 

echo -n  "Enter first DCD [ENTER]: "
read FIRST

echo -n  "Enter last DCD [ENTER]:  "
read LAST



#Constant varaibles, change when moving to a different system
INDEX_SCRIPT='/bgusr/home1/checkmat/antonio/scripts/pdb_zero_index_no_solv.pl'
CATDCD='/gpfs/DDNgpfs2/gdesktop/vmd-1.9.1/lib/vmd/plugins/LINUXPPC64/bin/catdcd4.0/catdcd'
DNAME='filtered'
CWD=pwd
SOURCED='r'

if [ ! -d "$DNAME" ]; then
    mkdir $DNAME 
fi



for i in `seq $FIRST $LAST`;
do
    cd $SOURCED$i 
    echo r$i
    pwd
    perl $INDEX_SCRIPT $PDB $RESNAME 
    wait
    $CATDCD -o $i.dcd  -i index.dat nat.$i*dcd
    wait
    mv $i.dcd index.dat No.$RESNAME.pdb ../$DNAME
    cd ../
done    

cd $DNAME

for i in `seq $FIRST $LAST`;
do
    DCD_ARG+=" $i.dcd" 
done

echo "concatenating $DCD_ARG dcds"
$CATDCD -o full.dcd $DCD_ARG
wait

for i in `seq $FIRST $LAST`;
do
    rm $i.dcd 
done


cd ../
    
