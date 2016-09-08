## INPUT ##

#Input PSF
set psf  ../PolarizeWater.psf
#Number of input dcd
set firstDCD 1
set lastDCD  1
set steps 0
set Nres 1824
set kAngle 0.35;  #1.003824
set kBond  120
set bondRef 1.40
#residue name of CG pol
# unique for each residue!!!!
set SingleName W 
#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    set dcd($i) "../eq$i.dcd"
}
#BA Topological Descriptors
 # DP = Distance of oxygen and positive particle
 # DW = Distance of oxygen and negative particle 
 # ANG  = WP-W-WM Angle    
set descriptors {DP DM MP EBONDP EBONDM ANG EANG DIPW }
#Atoms Names comprising each descriptor
set names(DP)     {W WP}
set names(DM)     {W WM}
set names(MP)     {WP WM}
set names(EBONDP) {W}
set names(EBONDM) {W}
set names(ANG)    {WP W WM}
set names(EANG)   {W}
set names(DIPW)   {W WP WM}
#Path to bigdcd script
set bigdcd ../../../../scripts/bigdcd.tcl
#outname
set outname CGPOL_BADE.dat
#First frame to perform analyes
set first 1
## END INPUT ##

## PROCEDURES ##
#they all work based on indexes (0 based)#
#Transforms name selections into indexes selections
proc SetIndex { descriptors SingleName &arrName } {
    upvar 1 ${&arrName} names
    set i 0;
    foreach resid [[atomselect top "name $SingleName"] get resid] segid [[atomselect top "name $SingleName"] get segid] {
	foreach  descriptor $descriptors {
	    set tempList {}
	    foreach name $names($descriptor) {
		lappend tempList [ [atomselect top "resid $resid and segid $segid and name $name"] get index]
	    }
	    set indexes($i,$descriptor) $tempList
	}
	incr i
    }
    return [array get indexes]
}

#Computes euclidian distance from a list of two atom indexes
proc distance { distance {k 0} {ref 0} } {
    set bondEne {}
    set index [lindex $distance 0]
    set coord1 [measure center [atomselect top "index $index"]]
    set index [lindex $distance 1]
    set coord2 [measure center [atomselect top "index $index"]]
    set distance [veclength [vecsub $coord1 $coord2]]
    lappend bondEne $distance
    if { $k } {
	set energy   [expr $k*($distance -$ref)*($distance-$ref)]
	lappend bondEne $energy
    } else {
	lappend bondEne 0
    }
    return $bondEne
}

#Computes angle from a list of three atom indexes
proc angle { angle {k 0} {ref 0} } {
    set angleEne {}
    set angle  [measure angle $angle ]
    lappend angleEne $angle 
    if { $k } {
	set angleRad [expr (3.14159*$angle)/180 ]
	set energy   [expr $k*($angleRad -$ref)*($angleRad-$ref)]
	lappend angleEne $energy
    } else {
	lappend angleEne 0
    }
    return $angleEne
}

#Computes dipole from a list of 3 atoms
proc dipoleW { dipole } {
    set sel [atomselect top "index [lindex $dipole 0] [lindex $dipole 1] [lindex $dipole 2] "]
    set vector [measure dipole $sel -debye -geocenter]
    set dip  [veclength $vector]
    $sel delete
    return $dip
}

# Run analyses of defined descriptors
proc RunAna {descriptors  NRes kAngle kBond bondRef &arrName } {
    upvar 1 ${&arrName} indexes
    foreach  descriptor $descriptors {
	set results($descriptor) { }
    }
    for {set i 0} {$i < $NRes} {incr i} {
	foreach  descriptor $descriptors {
	    if { $descriptor == "DP"} {
		set bondEne [ distance $indexes($i,$descriptor) $kBond $bondRef ]
		lappend results($descriptor) [lindex $bondEne 0]
		lappend results(EBONDP) [lindex $bondEne 1]
	    }
	    if { $descriptor == "DM"} {
		set bondEne [ distance $indexes($i,$descriptor) $kBond $bondRef ]
		lappend results($descriptor) [lindex $bondEne 0]
		lappend results(EBONDM) [lindex $bondEne 1]
	    }
	    if { $descriptor == "MP"} {
		set bondEne [ distance $indexes($i,$descriptor) $kBond $bondRef ]
		lappend results($descriptor) [lindex $bondEne 0]
	    }
	    if {$descriptor == "DIPW"} {
		lappend results($descriptor) [ dipoleW $indexes($i,$descriptor)]
	    }
	    if {$descriptor == "ANG"} {
		set angleEne [ angle $indexes($i,$descriptor) $kAngle ]
		lappend results($descriptor) [lindex $angleEne 0]
		lappend results(EANG) [lindex $angleEne 1]
	    }
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
	set sum 0
	foreach result $results($descriptor) {
	    set sum [expr $sum + $result]
	}
	set sum [expr $sum/[llength $results($descriptor)]]
	puts -nonewline $out [format {%10.2f} $sum]
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
    global descriptors names SingleName first outname steps Nres 
    global kAngle kBond bondRef
    array set indexes [SetIndex $descriptors $SingleName names]
    array set results [RunAna   $descriptors $Nres $kAngle $kBond $bondRef  indexes]
    incr steps
    WriteResult $descriptors $outname $steps results
}

## END PROCEDURES ##

## MAIN ##
proc main {&arrName} {
    upvar 1 ${&arrName} dcd 
    global psf numDCD bigdcd firstDCD lastDCD outname SingleName descriptors
    WriteInit $descriptors $outname 
    mol load psf $psf
    source $bigdcd
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    	puts "bigdcd";
	bigdcd RunTopo $dcd($i)
    	bigdcd_wait
    }
}

#### RUN ##

main dcd
puts "finished with $steps frames!!!"
exit
