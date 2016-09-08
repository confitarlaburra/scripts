#!/usr/bin/env python 
import os.path
# Generates the input files for a Ti (using prop dvdl (only potential energy)
# Then run runanalysys.csh to run the analysys with ene_ana
# Finally run TI_out.pl to get the the integrated delta G and the <dh/dl> profile


namebase ='TI_water_12'
lstart = 0.000
ldelta = 0.025
lend =   0.000
nsim = 2 
#topo = '6.6.water_5_wt.top'
library = '/home/jgarate/Gromos_Files/MD_files/ene_ana.md++.lib'

f=open('Volume_full_TI.arg','w')
#f.write('@topo ' + topo+'\n')
f.write('@prop boxvol \n')
f.write('@library ' + library +'\n')
f.write('@time 0 0.2\n')
f.write('@en_files \n')	 
while (lstart <= lend+1e-8):
	lstartString='{:.3f}'.format(lstart)
	path = 'L_'+lstartString	
	if os.path.isdir(path):
		#cnt assumes that first md is an equilibration
		cnt =2
		while (cnt <= nsim):
			jobnum = int(round(lstart*10000))+cnt
			f.write(path +'/' + namebase + '_'+str(jobnum) + '.tre.gz\n')
			cnt = cnt+1
	lstart = lstart+ldelta	
f.close()


