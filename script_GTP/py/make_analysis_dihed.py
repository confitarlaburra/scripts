#!/usr/bin/env python 


namebase ='TI_BR_GTP-GTP'

lstart = 0.0
ldelta = 0.1
lend = 1.0

nsim = 2 


while (lstart <= lend+1e-8):
	f=open('L_' +str(lstart) +'/tser.inp','w')
	f.write('@topo /home/jgarate/Gromos_Files/MD_files/GTP-BR+3NA.top\n')
	f.write('@pbc r cog\n')
	f.write('@traj\n ')
	cnt =2
	while (cnt <= nsim):
		jobnum = int(round(lstart*10000))+cnt
		f.write(namebase+'_'+str(jobnum) + '.trc.gz\n')
		cnt = cnt+1
	
	f.write('@prop\n tp%1:C4,N9,C1*,O4*\n')
	f.close()
	lstart = lstart+ldelta
