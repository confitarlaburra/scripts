#!/usr/bin/env python 
import os.path
# Generates the input files for a Ti (using prop dvdl (only potential energy)
# Then run runanalysys.csh to run the analysys with ene_ana
# Finally run TI_out.pl to get the the integrated delta G and the <dh/dl> profile


namebase ='TI_water_2_6.6'
lstart = 0.000
ldelta = 0.025
lend =   1.000
nsim = 2 
topo = 'SPC.12.6.6.13.inf.solv.top'

f=open('frame_out_full_TI.arg','w')
f.write('@topo ' + topo+'\n')
f.write('@pbc r cog \n')
f.write('@atomsfit 1:a\n')
f.write('@include SOLUTE \n')
f.write('@frames ALL  \n')
f.write('@outformat pdb \n')
f.write('@single \n')
f.write('@traj \n')	 
while (lstart <= lend+1e-8):
	lstartString='{:.3f}'.format(lstart)
	path = 'L_' +lstartString 	
	if os.path.isdir(path):
		#cnt assumes that first md is an equilibration
		cnt =2
		while (cnt <= nsim):
			jobnum = int(round(lstart*10000))+cnt
			f.write(path +'/' + namebase + '_'+str(jobnum) + '.trc.gz\n')
			cnt = cnt+1
	lstart = lstart+ldelta	
f.close()


