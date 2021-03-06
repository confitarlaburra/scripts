#
# Script computes order parameters  P1 =    <cos(theta)> 
# theta is the angle between the bilayer normal directed along z 
# and the unit dipole moment of water
 

set inputPDB final.pdb 
#
# SPC charges of O and H and number of slices 
# In PDB water are order as OW HW1 HW2
set poreRadius 5.045
set selTextPore "resname CCC"
set selection "type OW"
set resName "H2O"

set qH      0.410 
set qO     -0.820



proc setChargesSPC { qH qO } {
    set ow [atomselect top "type OW"] 
    set hw1 [atomselect top "type HW1"] 
    set hw2 [atomselect top "type HW2"]
    $ow set charge $qO
    $hw1 set charge $qH
    $hw2 set charge $qH
}



#orientation: assumes that pore is aligned in the z axis and centered in 0
#draws a vector from COM to dipole
proc DrawDipole { qH qO  selTextPore selection resName poreRadius {mol top} {color red} {scale 1.0} {radius 0.2} } {
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
    set partLoad [atomselect top "$selection  and  (x**2 +y**2)< $poreRadius**2 and z > $min_z and z < $max_z+0.8"]
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
	    graphics $mol color yellow
	    graphics $mol cylinder [vecsub $center $vechalf] \
                         [vecadd $center [vecscale 0.7 $vechalf]] \
                         radius $radius resolution $res filled $filled
	    graphics $mol color red
	    graphics $mol cone [vecadd $center [vecscale 0.7 $vechalf]] \
                         [vecadd $center $vechalf] radius [expr $radius * 1.7] \
                             resolution $res
	    
	}
    }
}
	

proc main {} {
    global  inputPDB poreRadius selection selTextPore resName  qH qO
    #mol load pdb $inputPDB
    setChargesSPC $qH $qO
    DrawDipole $qH $qO  $selTextPore $selection $resName $poreRadius
}




