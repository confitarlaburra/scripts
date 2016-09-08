#
# Script computes order parameters  P1 =    <cos(theta)> 
# theta is the angle between the bilayer normal directed along z 
# and the unit dipole moment of water
 

set inputPDB ../final.pdb 
#
# SPC charges of O and H and number of slices 
# In PDB water are order as OW HW1 HW2
set poreRadius 5.045
set selTextPore "resname CCC"
set selection "name CMe"
set resName "C3OH"

set qH      0.398 
set qO     -0.574
set qC      0.176


proc setChargesMetOH { qH qO qC } {
    set oMetOH [atomselect top "name Ome"] 
    set hMetOH [atomselect top "name HMe"] 
    set cMetOH [atomselect top "name Cme"]
    $oMetOH set charge $qO
    $hMetOH set charge $qH
    $cMetOH set charge $qC
}



#orientation: assumes that pore is aligned in the z axis and centered in 0
#draws a vector from COM to dipole
proc DrawDipole { selTextPore selection resName poreRadius {mol top} {color blue} {scale 1.0} {radius 0.2} } {
    #total mass for com 
    
    set res 6
    #set gidlist {}
    set filled yes
    
    set nano [atomselect top $selTextPore]
    set nano_min_max [measure minmax $nano]
    
    set min_xyz [lindex $nano_min_max 0]
    set max_xyz [lindex $nano_min_max 1]
    
    set min_z [lindex $min_xyz 2]
    set max_z [lindex $max_xyz 2]
    #
    # select waters
    #
    set partLoad [atomselect top "$selection  and  (x**2 +y**2)< $poreRadius**2 and z > $min_z and z < $max_z"]
    #
    # get list of resid 
    #
    set partResList [$partLoad get resid]
    # delete selection 
    #
    $partLoad delete
    #
    # if waters are selected then compute....
    #
    if { [llength $partResList] !=0 } {
	foreach resid $partResList   {
	    set sel [atomselect top "resname $resName and resid $resid "]
	    set center [measure center $sel]
	    set vector [measure dipole $sel -debye -geocenter]
	    set vechalf [vecscale [expr $scale * 0.5] $vector]
	    graphics $mol color blue
	    graphics $mol cylinder [vecsub $center $vechalf] \
                         [vecadd $center [vecscale 0.7 $vechalf]] \
                         radius $radius resolution $res filled $filled
	    graphics $mol color red
	    graphics $mol cone [vecadd $center [vecscale 0.7 $vechalf]] \
                         [vecadd $center $vechalf] radius [expr $radius * 2.0] \
                             resolution $res
	    
	}
    }
}
	

proc main {} {
    global  inputPDB poreRadius selection selTextPore resName  qH qO qC
    #mol load pdb $inputPDB
    setChargesMetOH $qH $qO $qC
    DrawDipole $selTextPore $selection $resName $poreRadius
}

#####
main

