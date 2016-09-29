#!/usr/bin/env python 


namebase ='TI_GTP-GTP-BR'

lstart = 0.0
ldelta = 0.1
lend = 1.0

nsim = 2 



while (lstart <= lend+1e-8):
	
	f=open('L_' +str(lstart) +'/ene_ana.inp','w')
	f.write('@fr_files ')
	cnt =2
	while (cnt <= nsim):
		jobnum = int(round(lstart*10000))+cnt
		f.write(namebase+'_'+str(jobnum) + '.trg.gz\n')
		cnt = cnt+1
	
	f.write('@prop totfren\n')
        f.write('@topo /home/jgarate/Gromos_Files/MD_files/GTP+3NA.top\n')
	f.write('@library /home/jgarate/Gromos_Files/MD_files/ene_ana.md++.lib\n')
	f.write('@time 0 0.2\n')
	f.close()
	lstart = lstart+ldelta



