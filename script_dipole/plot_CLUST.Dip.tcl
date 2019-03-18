## INPUT ##


# Lists
array set clusters {}
set dipoles {zero 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 90 100}
set cutOffs {0.20}
set MaxClustNum 65

#Init arrays
for {set i 0} {$i < [llength $dipoles] } {incr i} {
    for {set j 0} {$j < [llength $cutOffs] } {incr j} {
	for {set k 0} {$k < $MaxClustNum } {incr k} {
	    set clusters($i,$j,$k) 0
	}
    }
}


## PROCEDURES ##



#Cluster procedure to get cluster number for cluster(gromo++ program) 

proc GetClust {ClusterFile dipoleIndex cutOffIndex &arrName} {
    upvar 1 ${&arrName} clusters
    set pattern_D  {\s+(\d+)\s+(\d+)}
    set inStream [open $ClusterFile r]
    set j 0
    foreach line [split [read $inStream] \n] {
	if {[regexp $pattern_D $line match sub1 sub2]} { #element zero is not a cluster
	    set clusters($dipoleIndex,$cutOffIndex,$j) $sub2
	    incr j
	}
    }
    close $inStream
}
#
proc WriteClust { cutOffIndex &arrName } {
    global cutOffs dipoles MaxClustNum
    upvar 1 ${&arrName} clusters
    array set Totals {}
    for {set i 0} {$i < [llength $dipoles] } {incr i} {
	for {set j 0} {$j < [llength $cutOffs] } {incr j} {
	    set Totals($i,$j) 0
	}
    }
    for {set i 0} {$i < [llength $dipoles] } {incr i} {
	for {set j 0} {$j < [llength $cutOffs] } {incr j} {
	    for {set k 0} {$k < $MaxClustNum } {incr k} {
		set Totals($i,$j) [expr $Totals($i,$j) + $clusters($i,$j,$k)]
	    }
	}
    } 
    set cutOff  [lindex $cutOffs $cutOffIndex]
    set outName "ClusDens.$cutOff.dat"
    set out [open $outName w]
    puts $out "#Cluster Density for harmonic centers (dipole)"
    puts $out "#Cut off $cutOff"
    puts $out "#dipole     Cluster Index         Size"
    set bool 1
    for {set i 0} {$i < [llength $dipoles] } {incr i} {
	for {set j 0} {$j < $MaxClustNum } {incr j} {
	    if {$bool} {
		set dipole   [format {%11.2f}  -2.00]
	    } else {
		set dipole   [format {%11.2f}  [expr 0.1*[lindex $dipoles $i]]]
	    }
	    set ClustNum [format {%11.2f}  [expr $j+1]]
	    set Density  [format {%11.2f}  [expr 1.00*$clusters($i,$cutOffIndex,$j)/($Totals($i,$cutOffIndex)+1)]]
	    puts -nonewline $out $dipole
	    puts -nonewline $out $ClustNum
	    puts -nonewline $out $Density
	    puts $out ""
	}
	set bool 0
    }
    close $out
}

## END PROCEDURES ##

## MAIN ##
proc main  {} {
    global clusters dipoles cutOffs
    foreach dipole $dipoles {
	foreach cutOff $cutOffs {
	    set pathClust $dipole
	    append pathClust /out/filtered/cluster $cutOff /cluster.dat
	    GetClust $pathClust [lsearch $dipoles $dipole] [lsearch $cutOffs $cutOff] clusters
	}
    }
    # Write 3D plots of cluster index vs dipole vs density
    for {set i 0} {$i < [llength $cutOffs] } {incr i} {
	WriteClust $i clusters
    }
}
#### RUN ##
main 
exit
