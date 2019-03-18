## INPUT ##
### Run example :
# vmd -e Dipole_sec.tcl

#Input PSF
set psf /home/jgarate/work/dipole/BUILD/BUILD_12AM/input/12A_unsolvated.psf 
#Number of input dcd
set firstDCD 1
set lastDCD  2.0
set K 1.0
set out [open "TimeSeries.dat" w]
#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    #set dcds($i) full.dcd
    #set dcds($i) $i/filtered/full.dcd
    set j [expr $i + 1.0]
    puts $j
    set dcds($i) $j/out/filtered/full.dcd
    set outnameTS($i)   DipTs$j.dat
    set outnameHIS($i)  DipHIS$j.dat
    set outnameCorr($i) DipCorr$j.dat
    puts $out "DipTs$j  $j $K "
}
close $out
##########################################################################
#Path to bigdcd script
set bigdcd /home/jgarate/work/dipole/ANALYSIS/bigdcd.tcl
#Dipole Descriptors
set descriptors {DIPM}
set names(DIPM)  "protein"; # Selection for the total Dipole Moment

set first 1000; # First snapshot
set min 0;   # Min Dip Value
set max 10;  # Max Dip Value
set binNum 50; # Numbers of bins
set window 20000
## END INPUT ##
##########################################################################
### Do not Change!!!

set steps 0
set BinSize [expr 1.000*($max-$min)/$binNum]
# Set MAtrix of Dipoles and secondary elements
# And arrays for totals 
for { set i $firstDCD}  {$i <= $lastDCD} {incr i} {
    set DipolesM($i) {}
    for { set j 0}  {$j < $binNum} {incr j} {
	set DipTotals($i,$j) 0
    }
}

## PROCEDURES ##

########################################################################
#Transforms name selections into indexes selections
proc SetIndex { &arrName } {
    upvar 1 ${&arrName} names
    global descriptors
    foreach  descriptor $descriptors {
	#bad if descriport varies with order (e.g. torsion)
	set temp [ [atomselect top "$names($descriptor)"] get index]
	set indexes($descriptor) $temp
    }
    return [array get indexes]
}
#####################################################################
#dipole
# of a given (index-based) selection
# Returns dipole in A*e
proc dipoleCalc { dipole  } {
    set sel [atomselect top "index $dipole"]
    set dip [veclength [measure dipole $sel -masscenter]]
    $sel delete
    return $dip
}
#####################################################################
#Fill matrix of (dipole binned) secondary structure elements
# and fills dipole totals and hbonds totals
proc FillMatx { dipole &arrName } {
    global min max binNum
    global BinSize
    global dcd
    upvar 1 ${&arrName} DipTotals
    set step [expr int(( ($dipole-$min)/($BinSize) ))]
    if {$step >= 0 &&  $step < $binNum} {
	incr DipTotals($dcd,$step)
    }
}
######################################################################
proc unBin { traj &arrName1 &arrName2 } {
    global min max binNum
    global BinSize
    upvar 1 ${&arrName1} DipTotals
    upvar 1 ${&arrName2} outnameHIS
    set NormFact 0
    for {set i 0} {$i < $binNum} {incr i} {
	set NormFact [expr $DipTotals($traj,$i) + $NormFact]
    }
    set  out [open "$outnameHIS($traj)" w]
    puts $out "# Dip         Prob"
    for {set i 0} {$i < $binNum} {incr i} {
	set X     [expr  $i*$BinSize + $min + $BinSize*0.5]
	set Prob  [expr  1.000*$DipTotals($traj,$i)/$NormFact]
	#puts "PRob $DipTotals($traj,$i)"
	puts $out [format {%10.3f %10.3f} $X $Prob]
    }
    close $out
}
# Run analyses of defined descriptors
#######################################################################
proc WriteInit { &arrName } {
    upvar 1 ${&arrName} outnameTS
    global firstDCD lastDCD descriptors
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
	set out [open $outnameTS($i) w]
	puts -nonewline $out "# Frame "
	foreach  descriptor $descriptors {
	    puts -nonewline $out [ format {%10s} $descriptor]
	}
	puts $out ""
	close $out
    }
} 
#######################################################################
# Procedure to be run with bigdcd
proc RunTopo {frame} {
    global names first steps descriptors
    global outnameTS DipolesM
    incr steps
    # changeto steps if it is a single splitted MD
    # frames is reseted for every dcd
    if {$frame > $first } {
	array set indexes [SetIndex names]
	array set results [RunAna indexes DipolesM]
	WriteResult $frame results outnameTS
    }
}
#######################################################################
proc RunAna {&arrName1 &arrName2 } {
    upvar 1 ${&arrName1} indexes
    upvar 1 ${&arrName2} DipolesM
    global binNum 
    global DipTotals dcd
    set results(DIPM) [ dipoleCalc $indexes(DIPM) ]
    lappend DipolesM($dcd) $results(DIPM)
    FillMatx $results(DIPM) DipTotals
    return [array get results]
}
########################################################################
proc WriteResult {frame &arrName1 &arrName2} {
    upvar 1 ${&arrName1} results
    upvar 1 ${&arrName2} outnameTS
    global dcd descriptors
    set out [open $outnameTS($dcd) a+]
    puts -nonewline $out [format {%10s} $frame ]
    foreach  descriptor $descriptors {
	puts -nonewline $out [format {%10.3f} $results($descriptor)]
    }
    puts $out ""
    close $out
} 
########################################################################
proc Average { data } {
    set average 0
    foreach point $data {
	set average [expr $average + $point]
    }
    set average [expr 1.000*$average/[llength $data]]
    return $average
}

############################################################################

#Fluctuations SelfCorr
 #Computes self-correlation <(x(t)-uX) (x(0)-uX)>
 #Usage: SelfDipCorr $vecList $window $frames
 #veclist= vector list
 #window= windows to compute multiple origin averages
 #frames= number of elements to consider 
 #example : SelfDipCorr $vecList 100 [llength $vecList]

proc SelfCorr { data window dcd &arrName } {
    upvar 1 ${&arrName} outnameCorr
    ## init arrays 
    for {set i  0} {$i < $window} {incr i} { 
	set P1_list($i) 0;
	set average_counter($i) 0;
    }
    # Calculate average
    set Avrg [Average $data]
    set frames [llength $data]
    #Double loop; multiple windows, multiple origins
    for {set it  0} {$it < [expr $frames-$window]} {incr it} { 
	set window_counter  0;
	set vecit [expr [lindex $data $it] - $Avrg]
	for {set j  $it} {$j < [expr $it+$window] } {incr j} {
	    set vecj [ expr [lindex $data $j] - $Avrg]
	    set P1_list($window_counter) [expr $P1_list($window_counter)+ $vecit*$vecj];
	    incr average_counter($window_counter);
	    incr window_counter;
	}
    }
    set NormFact [expr $P1_list(0)/$average_counter(0)]
    set out [open "$outnameCorr($dcd).$window.dat" w]
    puts $out "#<(x(t)-uX) (x(0)-uX)> of Peptide "
    puts $out "#Window    <x*x>     "
    for {set i 0} {$i < $window} {incr i} {
	puts $out [format {%3d %10.5f} $i [expr $P1_list($i)/($average_counter($i)*$NormFact)]]
    }
    close $out
}
#######################################################################################################

## END PROCEDURES ##

## MAIN ##
proc main {&arrName } {
    upvar 1 ${&arrName} dcds 
    global psf bigdcd firstDCD lastDCD 
    global DipTotals outnameHIS outnameTS outnameCorr
    global DipolesM window
    
    WriteInit outnameTS
    mol load psf $psf    
    source $bigdcd
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
	global dcd
	set dcd $i
	bigdcd RunTopo $dcds($i)
    	bigdcd_wait
    }
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
	unBin $i DipTotals outnameHIS
	#SelfCorr $DipolesM($i) $window $i outnameCorr
    }
}

#### RUN ##

main dcds
puts "finished with $steps frames!!!"
exit
