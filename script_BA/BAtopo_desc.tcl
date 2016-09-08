## INPUT ##

#Input PSF
set psf  colanic_ch.box.ion.psf
#Number of input dcd
set firstDCD 3
set lastDCD  4
set steps 0
#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    set dcd($i) "eq$i.dcd"
}
#residue name of BA
set resname LIG 
#BA Topological Descriptors
 # DHO = Distance of carboxilate group relative to steroidal nucleus
 # CA  = Curvature of steroidal scaffold
 # O3  = Facial disposition of OH group 3    
 # O7  = Facial disposition of OH group 7
 # O12 = Facial disposition of OH group 12
 # H14 = Facial disposition of COO- group
set descriptors {CA O3 O7 O12 H14 DHO}
#Atoms Names comprising each descriptor
set names(CA)  {C2 C17 C16}
set names(O3)  {C3 C12 C17 C19}
set names(O7)  {C4 C16 C10 H17}
set names(O12) {C4 C16 C13 H20}
set names(H14) {H23 C14 C16 C1}
set names(DHO) {H23 C1}
#Path to bigdcd script
set bigdcd ../ana_scripts/bigdcd.tcl
#outname
set outname topo.dat
#First frame to perform analyes
set first 1
# set torsions from 0-360 (1) or -180 to 180 (0)
set period 0

## END INPUT ##



## PROCEDURES ##

#Transforms name selections into indexes selections
proc SetIndex { descriptors resname &arrName } {
    upvar 1 ${&arrName} names
    foreach  descriptor $descriptors {
	set tempList {}
	foreach name $names($descriptor) {
	    lappend tempList [ [atomselect top "resname $resname and name $name"] get index]
	}
	set indexes($descriptor) $tempList
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
proc dihed { Dihed period} {
    set Dihed  [measure dihed $Dihed ]
    if {$period} {
	if {$Dihed < 0} {
	    set Dihed [expr $Dihed + 360] 
	}
    }
    return $Dihed
}

#Computes angle from a list of three atom indexes
proc angle { angle } {
    set angle  [measure angle $angle ]
    return $angle
}


# Run analyses of defined descriptors
#2 indexes : Distance
#3 indexes : Angle
#4 indexes : Dihedral
proc RunAna {descriptors period &arrName } {
    upvar 1 ${&arrName} indexes
    foreach  descriptor $descriptors {
	if { [llength $indexes($descriptor)] == 2} {
	    set results($descriptor) [distance $indexes($descriptor)]
	}
	if { [llength $indexes($descriptor)] == 3} {
	    set results($descriptor) [angle $indexes($descriptor)]
	}
	if { [llength $indexes($descriptor)] == 4} {
	    set results($descriptor) [dihed $indexes($descriptor) $period]
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
    global descriptors names period resname first outname steps 
    array set indexes [SetIndex $descriptors $resname names]
    array set results [RunAna   $descriptors $period indexes]
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
