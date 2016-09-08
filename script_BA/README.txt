###############################
BAtopo_desc.tcl :
###############################
Computes Topological descriptors CA, O3, O7, O12, H14
For each molecules definitions for the descriptors need to be defined based on "names.txt" file.
Run it in simulation directory:
e.g. cd ../pyridyne/came/
     vmd -e ../../ana_scripts/BAtopo_desc.tcl
BAtopo_run.sh : executes BAtopo_desc.tcl , runs tcf to obtain statistics and put everything in topoBA directory
run it in simulation directory
e.g.
cd ../pyridyne/came/
../../ana_scripts/BAtopo_run.sh
################################
BA_RSR.tcl:
################################
Computes trajectory RMSD, RGYR and SASA for the whole molecule
Run it in simulation directory:
e.g. cd ../pyridyne/came/
     vmd -e ../../ana_scripts/BAtopo_desc.tcl

BA_RSR_run.sh:
Bash script that excutes BA_RSR.tcl:

run it in simulation directory
e.g.
cd ../pyridyne/came/
../../ana_scripts/BA_RSR_run.sh
##############################
catdcd_filt.sh:
##############################
filter all trajectories only leaving ligand. It uses pdb_filter.pl to get index file for catdcd. I writes output files in filetred directory.
eg. catdcd_filt.sh
for came pyridine:
../pyridyne/came/camefilteredpyridine/came.dcd
../pyridyne/came/camefilteredpyridine/came.psf

run it in ana_scripts directory:
e.g. 
catdcd_filt.sh
#########################
rmsf_rmsd_matx_aling.tcl
#########################
Computes rmsf and rmsd matrix for clustering. Additionally writes a new trajectory with the BA aligned  with the steroidal plane in the x-y plane, and the alpha and beta  positions pointing down and up respectively. For every molecules the rotations are to be changed in the "align" procedure!!!!

Preferentially run it after catdcd_filt.sh in filtered directory 
e.g.
cd ../pyridyne/came/camefilteredpyridine/
vmd -dispdev text -e ../../../ana_scripts/rmsf_rmsd_matx_aling.tcl 

Density plot can be calculated employing the volmap plugin of mvd over this trajectories:
Load a representative cluster:
VolMap 1.0 1.0 density norm avg
in single snapshot write all trajectories of terminal tail carbon
load volmap and color by volume the previous representation.
################
write_CLUST.tcl
###############
Writes representative clusters based on cluter ana from clster program and rmsd matrix from "rmsf_rmsd_matx_aling.tcl".
run it in simulation directory. Writes pdb with a solven shell based on a arbitrary cutoff.
e.g.
cd ../pyridyne/came/
../../ana_scripts/write_CLUST.tcl
##################
cluster.sh: 
##################
Excutes  write_CLUST.tcl for all simulations  and stores output files in cluster_$directory directory.
e.g.
cluster.sh
for came pyridine:
../pyridyne/came/camefilteredpyridine/cluster_0.15/




