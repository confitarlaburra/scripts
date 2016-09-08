#!/usr/local/bin/python2.7
import os

# Runs ene ana for the chosen properties
# Finally run TI_out_[propertie].pl to get the the integrated delta G and the <dh/dl> profile



library = "/home/fett/work/Gromos_Files/libraries/ene_ana.md++.lib"
currentPath = os.getcwd()
properties = ['dvdl', 'totfren', 'totfrspe']

dirs=[]
for root, rawdirs, files in os.walk('.'):
	for dirname in sorted(rawdirs):
		if dirname.startswith("L_"):
			dirs.append(dirname)
for path in dirs:
	#lstartString='{:.3f}'.format(lstart)
	if os.path.isdir(path):
		for index in range(len(properties)):
			f=open(path +'/ene_ana_'+properties[index]+'.inp','w')
			f.write('@fr_files ')
		
			files=[]
			os.chdir(path)
			for root, dirs, rawfiles in os.walk('.'):
				for filename in sorted(rawfiles):
					 if filename.endswith("trg.gz"):
						 files.append(filename)
			#cnt assumes that first md is an equilibration
			counter=False			 
			for file in files:
				if counter :
					f.write(file+'\n')
				counter=True
			f.write('@prop '+properties[index]+'\n')
			f.write('@library '+ library +'\n')
			f.write('@time 0 0.2\n')
			f.close()
			
			print path
			input = 'ene_ana @f ene_ana_'+properties[index]+'.inp >  ene_ana_'+properties[index]+'.out'
			print input			
			os.system(input)
			os.chdir(currentPath)
	


