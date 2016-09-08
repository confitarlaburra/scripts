#!/usr/local/bin/python2.7 
import os.path


namebase ='TI_load_8'
lstart = 0.000
ldelta = 0.100
lend =   0.800
nsim = 2 
topo = '9.CH4.6.6_3nm.topo.8.top '
#properties = ['d%2:OW;3:OW'] 
#properties = ['d%4:OW;va(cog,13:154, 153, 166, 165)', 'd%12:OW;va(cog,13:20,19,8,7)', 'd%10:OW;va(cog,13:298,297,310,309)']
properties = ['d%va(com,1:a);va(com,2:a)']
#properties = ['d%1:OW;va(cog,2:168  169 156  157)']
##MAIN###
f=open('tser_TI.arg','w')
f.write('@topo ' + topo+'\n')
f.write('@pbc r 6 \n')
f.write('@prop \n')
for index in range(len(properties)):
	f.write(properties[index]+'\n')
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

input = 'tser @f tser_TI.arg >  tser_TI.dat'
print input			
os.system(input)


