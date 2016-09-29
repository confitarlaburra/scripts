#!/usr/bin/env python 


namebase ='TI_GTP-GTP-BR_build_LE'

lstart = 0.0
ldelta = 0.1
lend = 1.0

nsim = 3 



while (lstart <= lend+1e-8):
	
	f=open('LE_TI_LC_' +str(lstart) +'/ene_ana.inp','w')
	f.write('@fr_files ')
	#Change to 2 if runnig a 1st eq run
	cnt =1
	while (cnt <= nsim):
		#jobnum = int(round(lstart*10000))+cnt
		f.write(namebase+'_'+str(lstart)+'_'+str(cnt) + '.trg.gz\n')
		cnt = cnt+1
	
	f.write('@prop dvdl\n')
        f.write('@topo /home/jgarate/Gromos_Files/MD_files/GTP+3NA.top\n')
	f.write('@library /home/jgarate/Gromos_Files/MD_files/ene_ana.md++.lib\n')
	f.write('@time 0 0.2\n')
	f.close()
	lstart = lstart+ldelta



