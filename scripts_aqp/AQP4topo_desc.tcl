## INPUT ##
### Run example :
# vmd -e AQP4topo_desc.tcl -args A 

#Input PSF
set psf  AQP_cw_pope_wi.psf
#Number of input dcd
set firstDCD 1
set lastDCD  1
set steps 0
#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    set dcd($i) "eq$i.dcd"; # change this 
}

#Path to bigdcd script
set bigdcd ../scripts/bigdcd.tcl

#set chain
set chain [lindex $argv 0] 
#AQP4 Descriptors
 # DSF1   = Distance NE2 of His 201 and Arg 216 NE    of chain $chain  
 # DSF2   = Distance NE2 of His 201 and Arg 216 NH1   of chain $chain
 # DSF3   = Distance NE2 of His 201 and Arg 216 NH2   of chain $chain
 # MINDSF = Min distance of DSF1, DSF2 and DSF3
 # DCE   = Distance NE2 of His 95  and Cys 178 SG    of chain $chain
 # DIH1  = Torsion of side-chain His-201 C-CA-CB-CG  of chain $chain
 # DIH2  = Torsion of side-chain His-95 C-CA-CB-CG   of chain $chain
 # DIA1  = Torsion of side-chain Arg-216 C-CA-CB-CG  of chain $chain
 # DIA2  = Torsion of side-chain Arg-216 CA-CB-CG-CD of chain $chain
 # DIA3  = Torsion of side-chain Arg-216 CB-CG-CD NE of chain $chain
 # DIA4  = Torsion of side-chain Arg-216 CG-CD-NE-CZ of chain $chain
 # DIP1  = P1 of His-201 
 # DIP2  = P1 of His-201 side chain
 # DIP3  = P1 of HIS-95
 # DIP4  = P1 of His-95 side chain
 # DIP5  = P1 of ARG-216 
 # DIP6  = P1 of ARG-216 side chain
set descriptors {DSF1 DSF2 DSF3 MINDSF DCE DIH1 DIH2 DIA1 DIA2 DIA3 DIA4 DIP1 DIP2 DIP3 DIP4 DIP5 DIP6}
# Selections comprising each descriptor 
set names(DSF1)  "(chain $chain and resid 201 and name NE2) or (chain $chain and resid 216 and name NE)"
set names(DSF2)  "(chain $chain and resid 201 and name NE2) or (chain $chain and resid 216 and name NH1)"
set names(DSF3)  "(chain $chain and resid 201 and name NE2) or (chain $chain and resid 216 and name NH2)"
set names(MINDSF) "chain H"
set names(DCE)   "(chain $chain and resid 95 and name NE2)  or (chain $chain and resid 178 and name SG)"
set names(DIH1)  "chain $chain and resid 201 and name C CA CB CG"
set names(DIH2)  "chain $chain and resid 95 and name C CA CB CG"
set names(DIA1)  "chain $chain and resid 216 and name C CA CB CG"
set names(DIA2)  "chain $chain and resid 216 and name CA CB CG CD"
set names(DIA3)  "chain $chain and resid 216 and name CB CG CD NE"
set names(DIA4)  "chain $chain and resid 216 and name CG CD NE CZ"
set names(DIP1)  "chain $chain and resid 201"
set names(DIP2)  "chain $chain and resid 201 and sidechain"
set names(DIP3)  "chain $chain and resid 95"
set names(DIP4)  "chain $chain and resid 95 and sidechain"
set names(DIP5)  "chain $chain and resid 216"
set names(DIP6)  "chain $chain and resid 216 and sidechain"

#outname
set outname $chain.dat
#First frame to perform analyes
set first 1
# set torsions from 0-360 (1) or -180 to 180 (0)
set period 0
# Return dipolar angle instead of cosine
set Angle 1
## END INPUT ##



## PROCEDURES ##
#this changes a bit
#Transforms name selections into indexes selections
proc SetIndex { descriptors  &arrName } {
    upvar 1 ${&arrName} names
    foreach  descriptor $descriptors {
	#bad if descriport varies with order
	set temp [ [atomselect top "$names($descriptor)"] get index]
	set indexes($descriptor) $temp
    }
    return [array get indexes]
}

#Computes euclidian distance from a list of two atom indexes
proc distance { distance } {
    set index [lindex $distance 0]
    set coord1 [measure center [atomselect top "index $index"]]
    set index [lindex $distance 1]
    set coord2 [measure center [atomselect top "index $index"]]
    set distance [veclength [vecsub $coord1 $coord2]]
    return $distance
}

#Computes torsion from a list of 4  atom indexes
#We need to re-arrange the selection thouhg, very lazy so
#Side torsion
proc dihedSC { Dihed descriptor period} {
    # bad solution for only dihed use script based on names and list adding indexes
    #C-CA-CB-Cg
    if {$descriptor == "DIA2" || $descriptor == "DIA3" || $descriptor == "DIA4" } {
	set Dihed  [measure dihed $Dihed ]
    } else {
	set reorder {}
	lappend reorder [lindex $Dihed 3]
	lappend reorder [lindex $Dihed 0]
	lappend reorder [lindex $Dihed 1]
	lappend reorder [lindex $Dihed 2]
	set Dihed  [measure dihed $reorder ]
    }
    if {$period} {
	if {$Dihed < 0} {
	    set Dihed [expr $Dihed + 360] 
	}
    }
    return $Dihed
}


#change it to compute the angle!!!
proc dipoleP1 { dipole Angle } {
    set sel [atomselect top "index $dipole"]
    set vector [measure dipole $sel -debye -geocenter]
    set dip  [veclength $vector]
    set dipdotn    [ expr [ lindex $vector 2 ] / $dip ]
    $sel delete
    if {$Angle } {
	return [expr 57.2958 * acos($dipdotn)] 
    } else {
	return $dipdotn
    }
}



# Run analyses of defined descriptors
#2 indexes   : Distance
#4 indexes   : Dihedral
#> 4 indexes : dipole
proc RunAna {descriptors period Angle &arrName } {
    upvar 1 ${&arrName} indexes
    set DSF_list {}
    foreach  descriptor $descriptors {
	if { [llength $indexes($descriptor)] == 2 && $descriptor != "DCE"} {
	    set results($descriptor) [distance $indexes($descriptor)]
	    lappend DSF_list $results($descriptor)
	}

	if { $descriptor == "DCE"} {
	    set results($descriptor) [distance $indexes($descriptor)]
	}
	
	if { [llength $indexes($descriptor)] == 4} {
	    set results($descriptor) [dihedSC $indexes($descriptor) $descriptor $period ]
	}
	if { [llength $indexes($descriptor)] > 4} {
	    set results($descriptor) [dipoleP1 $indexes($descriptor) $Angle ]
	}
    }

    foreach  descriptor $descriptors {
	if { [llength $indexes($descriptor)] == 0} {
	    set results($descriptor) [lindex [lsort $DSF_list ] 0]
	}
    }
    
    return [array get results]
}

#Writes results into a single File
proc WriteResult {descriptors outname frame &arrName} {
    upvar 1 ${&arrName} results
    set out [open $outname a+]
    puts -nonewline $out [format {%10s} $frame ]
    foreach  descriptor $descriptors {
	puts -nonewline $out [format {%10.2f} $results($descriptor)]
    }
    puts $out ""
    close $out
} 

#Write Initial file: The avoids deletion when loading multiple dcd in a for loop
proc WriteInit {descriptors outname} {
    set out [open $outname w]
    puts -nonewline $out "# Frame "
    foreach  descriptor $descriptors {
	puts -nonewline $out [ format {%10s} $descriptor]
    }
    puts $out ""
    close $out
} 


# Procedure to be run with bigdcd
proc RunTopo {frame} {
    global descriptors names Angle period  first outname steps 
    array set indexes [SetIndex $descriptors  names]
    array set results [RunAna   $descriptors $period  $Angle indexes]
    incr steps
    WriteResult $descriptors $outname $steps results
}

## END PROCEDURES ##

## MAIN ##
proc main {&arrName} {
    upvar 1 ${&arrName} dcd 
    global psf numDCD bigdcd firstDCD lastDCD outname descriptors
    WriteInit $descriptors $outname 
    mol load psf $psf    
    source $bigdcd
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    	bigdcd RunTopo $dcd($i)
    	bigdcd_wait
    }
}

#### RUN ##

main dcd
puts "finished with $steps frames!!!"
exit
