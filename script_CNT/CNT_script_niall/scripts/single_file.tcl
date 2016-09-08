#input
#non-periodic system
set psf_1 finite/6.6.4.0.periodic.40.box.psf
#final pdb of an open simulation with particles within the pore
set pdb_1 finite/final.pdb
set reference_pdb finite/6.6.4.0.periodic.40.box.pdb ; # CNT aligned in z
#periodic system
set psf_2 6.6.4.0.periodic.40.box.psf
set pdb_2 6.6.4.0.periodic.40.box.pdb
set topology  ../../conf_param/toppar_water_ions.str
set segment SWF
#CNT parameters
set lz 40 
set radius 3.8
# atoms to be removed from psf
set selection1  "(same residue as ( (x**2 + y**2) <= $radius**2) and z < $lz*0.5 and z > -$lz*0.5) "
# alignment selection
set selection2 "resname CNT"
set output1 single.file
set output2 6.6.4.0.periodic.40.box.$output1
## MAIN ## process
proc main {} {
    package require psfgen
    global psf_1 psf_2 pdb_1 pdb_2 reference_pdb
    global output1 output2 segment topology
    global length radius selection1 selection2

    mol load pdb $reference_pdb
    set all [atomselect top all]
    set CNT [atomselect top $selection2]
    $all moveby [vecinvert [measure center $CNT ] ]
    $all delete
    $CNT delete
    
    mol load psf $psf_1 pdb $pdb_1
    
    fit_2mol "resname CNT"

    mol delete 0

    #select atoms     
    set single [atomselect top "$selection1"]
   
    $single writepdb $output1.pdb
    mol delete all
    #write psf of  single water file
    resetpsf
    topology $topology
    segment $segment {pdb $output1.pdb}
    coordpdb $output1.pdb $segment
    writepsf $output1.psf
    writepdb $output1.pdb
    #combine with centered periodic tube aligned  in z
    resetpsf 
    readpsf  $psf_2
    coordpdb $pdb_2
    readpsf  $output1.psf
    coordpdb $output1.pdb
    writepsf $output2.psf
    writepdb $output2.pdb
    
    mol load psf $output2.psf pdb $output2.pdb
    set_beta $selection2 1.0 $output2
    
    
}

proc fit_2mol  { selection } {
    set ref [atomselect 0 "$selection"]
    set sel [atomselect top "$selection"]
    set all [atomselect top all]
    $all move [measure fit $sel $ref]
}

proc set_beta  { selection beta output } {
    set all [atomselect top all]
    $all set beta 0
    set sel [atomselect top "$selection"]
    $sel set beta $beta
    $all writepdb $output.fix
}
#run
main
exit
