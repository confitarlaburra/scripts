## INPUT ##
### Run example :
# vmd -e Dipole_sec.tcl

#Input PSF
#set psf /home/jgarate/dipole/BUILD/BUILD_12AM/input/12A.psf
#set psf /home/jgarate/dipole/BUILD/BUILD_12AM/input/12A_unsolvated.psf 
set psf /home/jgarate/dipole/BUILD/BUILD_ALAM/input/ALA.psf
#Number of input dcd
set firstDCD 0
set lastDCD  5
set j 0
#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {set i [expr $i +1]} {
#    set dcd($j) full.dcd
    #set dcd($j) $i/out/filtered/full.dcd
    set dcd($j) $i/out/eq1.dcd
    incr j
}

#set dcd($j) full.dcd
#Path to bigdcd script
set bigdcd /home/jgarate/dipole/ANALYSIS/bigdcd.tcl
#Dipole Descriptors
set descriptors {DIPM SEC ETED HBOND HBONDW}
set names(DIPM)  "protein"; # Selection for the total Dipole Moment
set names(SEC)   "protein and name CA"; # Selection for secondary structure calculation (Stride)
set names(HBOND) "protein and (oxygen or nitrogen)"; # Selection for Backbone H-bonds
set names(ETED)  "index 9 109"
set names(HBONDW) "protein and (oxygen or nitrogen)"; # Selection for Backbone H-bonds

set first 0; # First snapshot
set min 0;   # Min Dip Value
set max 10;  # Max Dip Value
set binNum 11; # Numbers of bins
set 2DEstList {H G I E B T C}; #Secondary Structure elements defined in Stride
set outname DipSec.dat

## END INPUT ##
#################################################################################################################################### 
### Do not Change!!!

set steps 0
set BinSize [expr 1.000*($max-$min)/$binNum]
# Set MAtrix of Dipoles and secondary elements
# And arrays for totals 
for { set i 0}  {$i < $binNum} {incr i} {
    set DipTotals($i) 0
    set DipHbonds($i) {}
    set DipHbondsW($i) {}
    set DipETED($i) {}
    foreach sec  $2DEstList {
	set DipMatx($i,$sec) 0
    }
}

## PROCEDURES ##


#Transforms name selections into indexes selections
proc SetIndex { descriptors  &arrName } {
    upvar 1 ${&arrName} names
    foreach  descriptor $descriptors {
	#bad if descriport varies with order (e.g. torsion)
	set temp [ [atomselect top "$names($descriptor)"] get index]
	set indexes($descriptor) $temp
    }
    return [array get indexes]
}

#Distance
proc distance { dist } {
    set index1   [lindex $dist 0]
    set index2   [lindex $dist 1]
    set coord1   [measure center [atomselect top "index $index1"]]
    set coord2   [measure center [atomselect top "index $index2"]]
    set distance [veclength [vecsub $coord1 $coord2]]
    #puts "distance $distance"
    return $distance
}

# calculate hbonds of (index-based) selection
# Returns total number of H-bonds
proc calc_hbond {hbonds } {
    set sel [atomselect top "index $hbonds"]
    set cutoff 3.5
    set angle  40
    set hbonds [llength [lindex [measure hbonds $cutoff $angle $sel] 0]]
    #puts "hbonds $hbonds"
    return $hbonds
}

proc calc_hbondW {} {
    set selP [atomselect top "protein"]
    set selW [atomselect top "water"]
    set cutoff 3.5
    set angle  40
    set hbondsDA [llength [lindex [measure hbonds $cutoff $angle $selP $selW] 0]]
    set hbondsAD [llength [lindex [measure hbonds $cutoff $angle $selW $selP] 0]]
    set Total [expr $hbondsDA*1.000 + $hbondsAD*1.000]
    #puts "water $Total"
    return $Total
}



#dipole
# of a given (index-based) selection
# Returns dipole in A*e
proc dipoleCalc { dipole  } {
    set sel [atomselect top "index $dipole"]
    set dip [veclength [measure dipole $sel -masscenter]]
    $sel delete
    return $dip
}

# Compute secondary structure of a given selection
# returns a list {HHHHHCC....}
# To remove redundancy just selects Ca
proc getSecEst { secondary } {
    set sel [atomselect top "index $secondary"]
    $sel set structure coil
    mol ssrecalc top
    return  [$sel get structure]
}


#Fill matrix of (dipole binned) secondary structure elements
# and fills dipole totals and hbonds totals
proc FillMatx { dipole secondaryList hbonds hbondsW distance &arrName1 &arrName2 &arrName3 &arrName4 &arrName5} {
    global min max binNum
    global BinSize
    upvar 1 ${&arrName1} DipMatx
    upvar 1 ${&arrName2} DipTotals
    upvar 1 ${&arrName3} DipHbonds
    upvar 1 ${&arrName4} DipETED
    upvar 1 ${&arrName5} DipHbondsW
    set step [expr int(( ($dipole-$min)/($BinSize) ))]
    if {$step >= 0 &&  $step < $binNum} {
	lappend DipHbonds($step) $hbonds
	#puts "$step W $DipHbondsW($step)"
	lappend DipHbondsW($step) $hbondsW
	lappend DipETED($step) $distance
	foreach sec $secondaryList {
	    incr DipTotals($step)
	    incr DipMatx($step,$sec)
	}
    }
}

#Compute average and error hbonds with tcf 
proc AvgHbonds { &arrName } {
    global binNum
    upvar 1 ${&arrName} DipHbonds
    set execName /home/jgarate/opt/gromos++/bin/tcf
    array set AvgHbond {}
    for { set i 0}  {$i < $binNum} {incr i} {
	set tcfinName  "hbonds.in"
	set tcfoutName "hbonds.out"
	set out [open $tcfinName w]
	lappend AvgHbond($i) -nan
	lappend AvgHbond($i) -nan
	foreach hbond $DipHbonds($i) {
	    puts $out  $hbond
	}
	close $out
	if [catch {exec $execName @files $tcfinName @distribution 1 > $tcfoutName }] {
	    puts "tcf: No hbonds found for bin $i"
	} else {
	    set inStream [open $tcfoutName r]
	    foreach line [split [read $inStream] \n] {
		if {[regexp {^\s+\S+\s+\S+\s+(\S+)\s+\S+\s+(\S+)} $line match average serror]} {
		    set AvgHbond($i) {}
		    lappend AvgHbond($i) "$average"
		    lappend AvgHbond($i) "$serror"
		    #puts "I $i  $AvgHbond($i)"
		}
	    }
	    close $inStream 
	}
	exec rm $tcfinName $tcfoutName 
    }
    return [array get AvgHbond]
}


#Voy aca 4.
#Compute average and error hbonds with water with tcf 
proc AvgHbondsW { &arrName } {
    global binNum
    upvar 1 ${&arrName} DipHbondsW
    set execName /home/jgarate/opt/gromos++/bin/tcf
    array set AvgHbondW {}
    for { set i 0}  {$i < $binNum} {incr i} {
	set tcfinName  "hbondsW.in"
	set tcfoutName "hbondsW.out"
	set out [open $tcfinName w]
	lappend AvgHbondW($i) -nan
	lappend AvgHbondW($i) -nan
	foreach hbond $DipHbondsW($i) {
	    puts $out $hbond
	}
	close $out
	if [catch {exec $execName @files $tcfinName @distribution 1 > $tcfoutName }] {
	    puts "tcf: No hbonds found for bin $i"
	} else {
	    set inStream [open $tcfoutName r]
	    foreach line [split [read $inStream] \n] {
		if {[regexp {^\s+\S+\s+\S+\s+(\S+)\s+\S+\s+(\S+)} $line match average serror]} {
		    set AvgHbondW($i) {}
		    lappend AvgHbondW($i) "$average"
		    lappend AvgHbondW($i) "$serror"
		    #puts "W  $i $AvgHbondW($i)"
		}
	    }
	    close $inStream 
	}
	exec rm $tcfinName $tcfoutName 
    }
    return [array get AvgHbondW]
}



#Compute average and error hbonds with tcf 
proc AvgDists { &arrName } {
    global binNum
    upvar 1 ${&arrName} DipETED
    set execName /home/jgarate/opt/gromos++/bin/tcf
    array set AvgDist {}
    for { set i 0}  {$i < $binNum} {incr i} {
	set tcfinName  "Dist.in"
	set tcfoutName "Dist.out"
	set out [open $tcfinName w]
	lappend AvgDist($i) -nan
	lappend AvgDist($i) -nan
	foreach dist $DipETED($i) {
	    puts $out $dist
	}
	close $out
	if [catch {exec $execName @files $tcfinName @distribution 1 > $tcfoutName }] {
	    puts "tcf: No hbonds found for bin $i"
	} else {
	    set inStream [open $tcfoutName r]
	    foreach line [split [read $inStream] \n] {
		if {[regexp {^\s+\S+\s+\S+\s+(\S+)\s+\S+\s+(\S+)} $line match average serror]} {
		    set AvgDist($i) {}
		    lappend AvgDist($i) "$average"
		    lappend AvgDist($i) "$serror"
		    #puts "D $i  $AvgDist($i)"
		}
	    }
	    close $inStream 
	}
	exec rm $tcfinName $tcfoutName 
    }
    return [array get AvgDist]
}


# Compute final percentages and Averages 
# and outputs everything
proc Comp2DPercent {&arrName1 &arrName2 } {
    global min max binNum BinSize
    global 2DEstList outname
    global DipHbonds DipHbondsW DipETED
    upvar 1 ${&arrName1} DipMatx
    upvar 1 ${&arrName2} DipTotals
    set dipTot 0
    for { set i 0}  {$i < $binNum} {incr i} {
	set dipTot [expr $dipTot + $DipTotals($i)]
    }
    foreach sec  $2DEstList {
	set SecTot($sec) 0
    }
    array set AvgHbond  [AvgHbonds  DipHbonds]
    array set AvgHbondW [AvgHbondsW DipHbondsW]
    array set AvgDist   [AvgDists  DipETED]
    set out [open $outname w]
    puts -nonewline $out "#Dip"
    puts -nonewline $out [format {%11s} "%"]
    foreach  sec  $2DEstList { 
        puts -nonewline $out [ format {%11s} $sec]
    }
    puts -nonewline $out [format {%11s} "HbondsI"]
    puts -nonewline $out [format {%11s} "Error"]

    puts -nonewline $out [format {%11s} "HbondsW"]
    puts -nonewline $out [format {%11s} "Error"]

    puts -nonewline $out [format {%11s} "ETED"]
    puts -nonewline $out [format {%11s} "Error"]
    
    puts $out ""
    for { set i 0}  {$i < $binNum} {incr i} {
	set dipole [format {%0.2f} [expr $i*$BinSize + $min + $BinSize*0.5]]
	set percentageD [format {%11.2f} [expr 1.00*$DipTotals($i)*100/$dipTot] ]
	puts -nonewline $out $dipole
	puts -nonewline $out $percentageD
	foreach sec  $2DEstList {
	    if {$DipTotals($i) > 0} {
		set percentage   [expr (1.00*$DipMatx($i,$sec)/$DipTotals($i))*100]
		set SecTot($sec) [expr $SecTot($sec) + $DipMatx($i,$sec)]
		puts -nonewline $out [format {%11.2f} $percentage]
	    } else {
		set percentage [format {%11.2f} 0 ]
		puts -nonewline $out $percentage
	    }
	}
	if { [lindex $AvgHbond($i) 0] >= 0 } {
	    puts -nonewline $out [format {%11.2f} [expr 1.00*[lindex $AvgHbond($i) 0]]]
	} else {
	    puts -nonewline $out [format {%11s} [lindex $AvgHbond($i) 0]]
	}
	if { [lindex $AvgHbond($i) 1] >= 0 } {
	    puts -nonewline $out [format {%11.2f} [expr 1.00*[lindex $AvgHbond($i) 1]]]
	} else {
	    puts -nonewline $out [format {%11s} [lindex $AvgHbond($i) 1]]
	}
	if { [lindex $AvgHbondW($i) 0] >= 0 } {
	    #puts "W $i $AvgHbondW($i)"
	    puts -nonewline $out [format {%11.2f} [expr 1.00*[lindex $AvgHbondW($i) 0]]]
	} else {
	    puts -nonewline $out [format {%11s} [lindex $AvgHbondW($i) 0]]
	}
	if { [lindex $AvgHbondW($i) 1] >= 0 } {
	    puts -nonewline $out [format {%11.2f} [expr 1.00*[lindex $AvgHbondW($i) 1]]]
	} else {
	    puts -nonewline $out [format {%11s} [lindex $AvgHbondW($i) 1]]
	}
	if { [lindex $AvgDist($i) 0] >= 0 } {
	    puts -nonewline $out [format {%11.2f} [expr 1.00*[lindex $AvgDist($i) 0]]]
	} else {
	    puts -nonewline $out [format {%11s} [lindex $AvgDist($i) 0]]
	}
	if { [lindex $AvgDist($i) 1] >= 0 } {
	    puts -nonewline $out [format {%11.2f} [expr 1.00*[lindex $AvgDist($i) 1]]]
	} else {
	    puts -nonewline $out [format {%11s} [lindex $AvgDist($i) 1]]
	}
	
	puts $out ""
    }
    puts -nonewline $out "#TS%"
    puts -nonewline $out [format {%11s} ""]
    
    foreach sec  $2DEstList {
	set percentageSec [expr (1.00*$SecTot($sec)/$dipTot)*100]
	puts -nonewline $out [format {%11.2f} $percentageSec]
    }
    close $out
}


# Run analyses of defined descriptors

proc RunAna {&arrName } {
    upvar 1 ${&arrName} indexes
    global binNum 
    global DipMatx DipTotals DipHbonds DipHbondsW DipETED
    set dipoleM [ dipoleCalc $indexes(DIPM) ]
    set secondaryList [ getSecEst $indexes(SEC) ]
    set hbonds  [calc_hbond  $indexes(HBOND)]
    set hbondsW [calc_hbondW ]
    set EndDist [distance $indexes(ETED)]
    FillMatx $dipoleM $secondaryList $hbonds $hbondsW $EndDist DipMatx DipTotals DipHbonds DipETED DipHbondsW 
}



# Procedure to be run with bigdcd
proc RunTopo {frame} {
    global names first steps descriptors
    incr steps
    if {$steps > $first } {
	array set indexes [SetIndex $descriptors names]
	RunAna indexes
    }
}
## END PROCEDURES ##

## MAIN ##
proc main {&arrName } {
    upvar 1 ${&arrName} dcd 
    global psf bigdcd firstDCD lastDCD 
    global DipMatx DipTotals    
    mol load psf $psf    
    source $bigdcd
    set j 0
    for {set i $firstDCD} {$i <= $lastDCD} {set i [expr  $i + 5]} {
    	bigdcd RunTopo $dcd($j)
    	bigdcd_wait
	incr j
    }
    Comp2DPercent DipMatx DipTotals
}

#### RUN ##

main dcd
puts "finished with $steps frames!!!"
#exit
