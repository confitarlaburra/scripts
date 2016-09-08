#!/bin/bash

#Script that copy everything to an alternate dropbox folder run it in ana_script directory

DNAME='filtered'
DESTFOLD='/home/fett/.dropbox-alt/Dropbox/BA_2015/'
CWD=$PWD

if [  -d "$DESTFOLD" ]; then
    rm -r $DESTFOLD 
fi
mkdir $DESTFOLD

for  i in CDCA_ch iDCA_ch iLCA_ch lagoCA lagoDCA_ch LCA_ch DCA_ch 3DOXCA_ch 3DOXCDCA_ch 3DOXDCA_ch 3DOXlagoCA_ch 3DOXlagoDCA_ch 3DOXlagoUCA_ch 3DOXUCA_ch 3DOXUDCA_ch CA CA_ion iCA ilagoCA ilagoUCA iUCA lagoCA lagoUCA UCA colanic_ch iCDCA_ch CDCA_ch iUDCA_ch UDCA_ch ilagoDCA_ch 
do	
    if [  -d "$DESTFOLD/$i" ]; then
	rm -r $DESTFOLD/$i 
    fi
    
    echo $i
    cd ../$i
    pwd
    
    if [ -d "build" ]; then
	mkdir $DESTFOLD/$i
	cp -r build $DESTFOLD/$i
    fi


    if [ -d "BAtopo" ]; then
	#mkdir $DESTFOLD/$i
	cp -r BAtopo $DESTFOLD/$i
    fi
    
    if [ -d "BA_RMSD_RGYR_SASA" ]; then
	cp -r BA_RMSD_RGYR_SASA $DESTFOLD/$i
    fi

    if [  -d "$i$DNAME" ]; then
	cd  $i$DNAME
	cp -r cluster*  $DESTFOLD/$i
	cp -r $i.dcd $i.psf $DESTFOLD/$i
	cd ../	
    fi
    cd ../
    cd $CWD
done
pwd
