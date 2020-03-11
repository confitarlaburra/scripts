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
INDEX_SCRIPT='/home/jgarate/dipole/ANALYSIS/pdb_zero_index_no_solv.pl'
CATDCD='/usr/local/bin/catdcd'
DNAME='filtered'
CWD=pwd
SOURCED='r'

if [ ! -d "$DNAME" ]; then
    mkdir $DNAME 
fi



for i in `seq $FIRST $LAST`;
do
    #cd $SOURCED$i 
    #echo r$i
    pwd
    perl $INDEX_SCRIPT $PDB $RESNAME 
    wait
    $CATDCD -o filt.$i.dcd -i index.dat $i.dcd 
    wait
    mv filt.$i.dcd index.dat No.$RESNAME.pdb $DNAME
    #cd ../
done    

cd $DNAME

for i in `seq $FIRST $LAST`;
do
    DCD_ARG+=" filt.$i.dcd" 
done

echo "concatenating $DCD_ARG dcds"
$CATDCD -o full.dcd $DCD_ARG
wait

for i in `seq $FIRST $LAST`;
do
    rm filt.$i.dcd 
done


cd ../
    
