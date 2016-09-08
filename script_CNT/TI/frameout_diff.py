#!/usr/bin/env python 
#import os
import os

# Generates the input files for a Ti (using prop totfren total energy)
# Then run runanalysys_top.csh to run the analysys with ene_ana
# Finally run TI_out_tot.pl to get the the integrated delta G and the <dh/dl> profile


namebase ='TI_water_1_6.6_inf'
lstart = 0.000
ldelta = 1.000
lend =   0.000
nsim = 2
topo = '../SPC.12.6.6.13.inf.solv.top'
ref = '../12.SPC.6.6.3nm.inf.min.cnf'
ts = '1'
dim = 'z'
atoms ='1-12:OW'
currentPath = os.getcwd()
while (lstart <= lend+1e-8):
	lstartString='{:.3f}'.format(lstart)
	path = 'L_' +lstartString
	if os.path.isdir(path):
		f=open(path+'/frame_out_full_TI.arg','w')
		f.write('@topo ' + topo+'\n')
		f.write('@pbc r cog \n')
		f.write('@atomsfit a:C1,C2,C3,C4\n')
		f.write('@ref '+ ref +'\n')
		f.write('@include SOLUTE \n')
		f.write('@frames ALL  \n')
		f.write('@outformat trc \n')
		f.write('@single \n')
		f.write('@traj \n')
		#cnt assumes that first md is an equilibration
		cnt =2
		while (cnt <= nsim):
			jobnum = int(round(lstart*10000))+cnt
			f.write(namebase+'_'+str(jobnum) + '.trc.gz\n')
			cnt = cnt+1
		f.close()
		f=open(path+'/difussion1d.arg','w')
		f.write('@topo ' + topo+'\n')
		f.write('@pbc r  \n')
		f.write('@time 0 '+ ts + '\n')
		f.write('@dim '+ dim + '\n')
		f.write('@atoms '+ atoms + '\n')
		f.write('@traj FRAME_00001.trc\n')
		f.close()
		os.chdir(path)
		os.system("frameout @f frame_out_full_TI.arg" )
		os.system("diffus @f difussion1d.arg ")
		os.chdir(currentPath)
	lstart = lstart+ldelta



