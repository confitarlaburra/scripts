## INPUT ##
### Run example :
# vmd -e AQP4topo_desc.tcl -args A 

#Input PSF
set psf  /home/jgarate/dipole/12AM/common/12A.psf
#set psf /home/jgarate/dipole/BUILD/BUILD_12AM/input/12A_unsolvated.psf
set psf /home/jgarate/dipole/BUILD/BUILD_ARGM/input/ARG.psf
#Number of input dcd
set firstDCD 0
set lastDCD  5
set steps 0
set j 0
#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {set i [expr $i + 1]} {
    #set dcd($i) "12A_out_2.dcd"; # change this
    #set dcd($i) "12A_out.dcd"; # change this
    #set dcd($i) "12A_out_$i.dcd"; # change this
    #set dcd($i) $i.dcd;
    #set dcd($j) full.dcd
    #set dcd($j) $i/out/filtered/full.dcd
    set dcd($j) $i/out/eq1.dcd
    #put $i
    incr j
}

#Path to bigdcd script
set bigdcd /home/jgarate/dipole/ANALYSIS/bigdcd.tcl

#set reference vector
# for fix axis 
#set reference {"fix" 2}; #set reference {"fix" axis_index }
# for a relative axis
#set reference {7 98 "origin"}
#or
set reference {3 113 "inst"}
set window 2000
#Dipole Descriptors
#Dipole Magnitude        DIPM
#Dipole Angle of Peptide DIPA
#End to End distance ETED
set descriptors {DIPM DIPA ETED HBONDS HBONDSW}
#empy list that stores vectors
set DipoleVecs {}
set RefVecs {}
# Selections comprising each descriptor 

set names(DIPA)  "protein"
set names(DIPM)  "protein"
set names(ETED)  "index 3 16"
set names(HBONDS) "protein and (oxygen or nitrogen)"
#For lazyness, this selection is useless. Hard-coded for protein-water
set names(HBONDSW) "protein" 
#outname
set outname DecaDip.dat
#First frame to perform analyes
set first 0
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

#Distance
proc distance { dist } {
    set index1   [lindex $dist 0]
    set index2   [lindex $dist 1]
    set coord1   [measure center [atomselect top "index $index1"]]
    set coord2   [measure center [atomselect top "index $index2"]]
    set distance [veclength [vecsub $coord1 $coord2]]
    return $distance
}

# calculate hbonds
proc calc_hbond {hbonds } {
    set sel [atomselect top "index $hbonds"]
    set cutoff 3.5
    set angle  40
    set hbonds [llength [lindex [measure hbonds $cutoff $angle $sel] 0]]
    return $hbonds
}

#Due to laziness, the selections are hard-coded
proc calc_hbondW {} {
    set selP [atomselect top "protein"]
    set selW [atomselect top "water"]
    set cutoff 3.5
    set angle  40
    set hbondsDA [llength [lindex [measure hbonds $cutoff $angle $selP $selW] 0]]
    set hbondsAD [llength [lindex [measure hbonds $cutoff $angle $selW $selP] 0]]
    set Total [expr $hbondsDA*1.000 + $hbondsAD*1.000]
    return $Total
}


#SelfDipCorr
 #Computes self-correlation <vec(t)dot vec(0)>
 #Usage: SelfDipCorr $vecList $window $frames
 #veclist= vector list
 #window= windows to compute multiple origin averages
 #frames= number of elements to consider 
 #example : SelfDipCorr $vecList 100 [llength $vecList]

proc SelfDipCorr { vecList window frames } {
    array set  P1_list {}
    # 1d vector to count for averaging
    array set average_counter {}
    ## init arrays 
    for {set i  0} {$i < $window} {incr i} { 
	set P1_list($i) 0;
	set average_counter($i) 0;
    }
    #Double loop
    for {set it  0} {$it < [expr $frames-$window]} {incr it} { 
	set window_counter  0;
	puts "it $it"
	set vecit [lindex $vecList $it]
	for {set j  $it} {$j < [expr $it+$window] } {incr j} {
	    set vecj [lindex $vecList $j]
	    set P1_list($window_counter) [expr $P1_list($window_counter)+ [vecdot $vecj $vecit]];
	    incr average_counter($window_counter);
	    incr window_counter;
	}
    }
    set out [open "Mu_tcorr.$window.dat" w]
    puts $out "#<mu(t)dot mu(t0) of Peptide "
    puts $out "#Window    <mu*mu>     "
    for {set i 0} {$i < $window} {incr i} {
	puts $out [format {%3d %10.5f} $i [expr $P1_list($i)/$average_counter($i)]]
    }
    close $out
}


#RefDipCorr
 #Computes correlation against a reference  vector<vec(t)dot ref(0)>
 #Usage: RefDipCorr  $vecList $ref $window $frames
 #veclist= vector list
 #set reference vector
 # for fix axis 
 #set reference {"fix" 2}; #set reference {"fix" axis_index 0}
 # for a relative axis
 #set reference {3 113}, each number is an atom index
 #window= windows to compute multiple origin averages
 #frames= number of elements to consider 
 #example : SelfDipCorr $vecList {fix 2} 100 [llength $vecList]

proc RefDipCorr { vecList refVecList ref window frames } {
    array set  P1_list {}
    array set average_counter {}
    for {set i  0} {$i < $window} {incr i} { 
	set P1_list($i) 0;
	set average_counter($i) 0;
    }
    if { [lindex $ref 0] == "fix"} { 
	if {[lindex $ref 1]==0} {
	    set refVec {1 0 0}  
	} elseif {[lindex $ref 1]==1} {
	    set refVec {0 1 0} 
	} else {
	    set refVec {0 0 1}
	}
    }
    #puts $refVec
    for {set it  0} {$it < [expr $frames-$window]} {incr it} { 
	set window_counter  0;
	if {[lindex $ref 2]== "origin"} {
	    set refVec [lindex $refVecList $it]
	    #puts $refVec
	}
	for {set j  $it} {$j < [expr $it+$window] } {incr j} {
	    if {[lindex $ref 2]== "inst"} {
		set refVec [lindex $refVecList $j]
	    }
	    #puts $refVec
	    set vecj [lindex $vecList $j]
	    set P1_list($window_counter) [expr $P1_list($window_counter)+ [vecdot $vecj $refVec]];
	    incr average_counter($window_counter);
	    incr window_counter;
	}
    }
    set out [open "Reftcorr.$window.dat" w]
    puts $out "#<mu(t)dot ref(0) of Peptide "
    puts $out "#Window          <mu*mu>     "
    for {set i 0} {$i < $window} {incr i} {
	puts $out [format {%3d %10.5f} $i [expr $P1_list($i)/$average_counter($i)]]
    }
    close $out
}

#Angle:
#Computes angle (in deg) of two verctor
#usage angle $vector1 $vector2
proc angle { a b } { 
   # Angle between two vectors 
   set amag [veclength $a] 
   set bmag [veclength $b] 
   set dotprod [vecdot $a $b] 
   return [expr 57.2958 * acos($dotprod / ($amag * $bmag))] 
} 

#dipole
#Computes dipole vector and angle against a ref vector
 # of a give selection
 #set reference vector
 # for fix axis 
 #set reference {"fix" 2}; #set reference {"fix" axis_index 0}
 # for a relative axis
 #set reference {3 113}, each number is an atom index
#Returns list {angle dipole magnitude}
proc dipole { dipole ref } {
    global DipoleVecs
    global RefVecs
    set temp {}
    set sel       [atomselect top "index $dipole"]
    #set vectorDip [measure dipole $sel -debye -masscenter]
    set vectorDip [measure dipole $sel  -masscenter]
    # append normalized dipole vectors 
    lappend DipoleVecs [vecnorm $vectorDip]
    set dip       [veclength $vectorDip]
    lappend temp $dip
    $sel delete
    if { [lindex $ref 0] == "fix"} { 
	set dipdotn    [ expr [ lindex $vectorDip [lindex $ref 1] ] / $dip ]
	lappend temp [expr 57.2958 * acos($dipdotn)]
	return $temp
    } else {
	set index [lindex $ref 0]
	set vec1  [measure center [atomselect top "index $index"]]
	set index [lindex $ref 1]
	set vec2  [measure center [atomselect top "index $index"]]
	set vecRef   [vecsub $vec2 $vec1]
	lappend RefVecs [vecnorm $vecRef] 
	lappend temp [angle $vectorDip $vecRef]
	return $temp  
    }
}



# Run analyses of defined descriptors

proc RunAna {descriptors reference &arrName } {
    upvar 1 ${&arrName} indexes
    set DIP_list [dipole $indexes(DIPA) $reference]
    foreach  descriptor $descriptors {
	if {$descriptor == "DIPA"} {
	    set results($descriptor) [lindex $DIP_list  1]
	}
	if {$descriptor == "DIPM"} {
	    set results($descriptor) [lindex $DIP_list  0]
	}
	if {$descriptor == "ETED"} {
	    set results($descriptor) [distance $indexes($descriptor)]
	}
	if {$descriptor == "HBONDS"} {
	    set results($descriptor) [calc_hbond $indexes($descriptor)]
	}
	if {$descriptor == "HBONDSW"} {
	    set results($descriptor) [calc_hbondW ]
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
	puts -nonewline $out [format {%10.3f} $results($descriptor)]
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
    global descriptors names first  steps reference outname
    incr steps
    if {$steps > $first } {
	array set indexes [SetIndex $descriptors names]
	array set results [RunAna   $descriptors $reference indexes]
	WriteResult $descriptors $outname $steps results
    }
}
## END PROCEDURES ##

## MAIN ##
proc main {&arrName} {
    upvar 1 ${&arrName} dcd 
    global psf numDCD bigdcd firstDCD lastDCD descriptors
    global DipoleVecs RefVecs steps reference window outname
    WriteInit $descriptors $outname 
    mol load psf $psf    
    source $bigdcd
    set j 0
    for {set i $firstDCD} {$i <= $lastDCD} {set i [expr  $i + 1]} {
	puts "trajectory $i"
	bigdcd RunTopo $dcd($j)
    	bigdcd_wait
	incr j
    }
    #RefDipCorr  $DipoleVecs $RefVecs $reference $window [llength $DipoleVecs]
    #SelfDipCorr $DipoleVecs $window [llength $DipoleVecs]
}

#### RUN ##

main dcd
puts "finished with $steps frames!!!"
exit
