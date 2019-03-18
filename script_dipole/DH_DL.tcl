## INPUT ##
### Run example :
# vmd -e AQP4topo_desc.tcl -args A 

#Input PSF
#set psf  /home/jgarate/work/dipole/12AM/common/12A.psf
set psf /home/jgarate/work/dipole/BUILD/BUILD_12AM/input/12A_unsolvated.psf 
#Number of input dcd
set firstDCD 1
set lastDCD  1

#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    #set dcd($i) "12A_out_2.dcd"; # change this
    #set dcd($i) "12A_out.dcd"; # change this
    #set dcd($i) "12A_out_$i.dcd"; # change this
    #set dcd($i) $i.dcd;
    set dcd($i) full.dcd
}

#Path to bigdcd script
set bigdcd /home/jgarate/work/dipole/ANALYSIS/bigdcd.tcl

#set reference vector
# for a relative axis
set reference {3 113 "origin"}
#or
#set reference {3 113 "inst"}
set window 2000
#Dipole Descriptors
set descriptors {dHdL}
# Selections comprising each descriptor 
set names(dHdL)  "protein"
# spring constants  
set k1 0
set k2 0.001
# actual lambda point
set lambda 0
set alpha 1
# reference angle
set Aref 60
#outname
set outname dHdL.dat
#First frame to perform analyes
set first 0
## END INPUT ##
set steps 0; # Do not change


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

# dipoleHRdHdL
#Computes dHdL for a harmonic restraint of dipole 
# H(lambda) = 0.5*(angle-ref)^2*alpha*lambda^(alpha-1)*(k2-k1)
# dipole    = list of atomo indexes that define the dipole 
# ref       = list of two indexes that defines a reference vector
# k1        = spring constat for state A (lambda=0)
# k2        = spring constat for state B (lambda=1)
# lambda    = current lambda point
# alpha     = power dependence of lambda
# Aref      = reference angle for harmonic restrarint  

proc dipoleHRdHdL { dipole ref } {
    global k1 k2 lambda alpha Aref
    set dHdL {}
    set sel       [atomselect top "index $dipole"]
    set vectorDip [measure dipole $sel -masscenter]
    $sel delete
    # append normalized dipole vectors 
    set dip      [veclength $vectorDip]
    set index    [lindex $ref 0]
    set vec1     [measure center [atomselect top "index $index"]]
    set index    [lindex $ref 1]
    set vec2     [measure center [atomselect top "index $index"]]
    set vecRef   [vecsub $vec2 $vec1]
    set Angle    [angle $vectorDip $vecRef]
    if {$alpha ==1 } {
	set dHdL [expr 0.5*($Angle-$Aref)*($Angle-$Aref)*($k2-$k1)]
    } else {
	set dHdL [expr 0.5*($Angle-$Aref)*($Angle-$Aref)*($alpha)*pow($lambda,$alpha-1)*($k2-$k1)]
    }
    return $dHdL
}



# Run analyses of defined descriptors

proc RunAna {descriptors reference &arrName } {
    upvar 1 ${&arrName} indexes
    foreach  descriptor $descriptors {
	if {$descriptor == "dHdL"} {
	    set results($descriptor) [dipoleHRdHdL $indexes(dHdL) $reference]
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
    global steps reference window outname
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
