## INPUT ##

#Input PSF
#set array to be a global variable

array set clusters {}
## END INPUT ##

set cutOffs {0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80}
set MaxClustNum 10
for {set i 0} {$i < [llength $cutOffs] } {incr i} {
    for {set j 0} {$j < $MaxClustNum } {incr j} {
	set clusters($i,$j) 0
    }
}


## PROCEDURES ##



#Cluster procedure to get cluster number for cluster(gromo++ program) 

proc GetClust {ClusterFile cutOffIndex &arrName} {
    upvar 1 ${&arrName} clusters
    set pattern_D  {\s+(\d+)\s+(\d+)}
    set inStream [open $ClusterFile r]
    set j 0
    foreach line [split [read $inStream] \n] {
	if {[regexp $pattern_D $line match sub1 sub2]} { #element zero is not a cluster
	    set clusters($cutOffIndex,$j) $sub2
	    incr j
	}
    }
    close $inStream
}
proc WriteClust {&arrName} {
    global cutOffs MaxClustNum
    upvar 1 ${&arrName} clusters
    array set Totals {}
    for {set i 0} {$i < [llength $cutOffs] } {incr i} {
	    set Totals($i) 0
    }
    for {set i 0} {$i < [llength $cutOffs] } {incr i} {
	for {set j 0} {$j < $MaxClustNum } {incr j} {
	    set Totals($i) [expr $Totals($i) + $clusters($i,$j)]
	}
    }
    set out [open "ClusDens.dat" w]
    puts $out "#Cluster Density for Cutoffs"
    puts $out "#cutoff     Cluster Index         Size"
    for {set i 0} {$i < [llength $cutOffs] } {incr i} {
	for {set j 0} {$j < $MaxClustNum } {incr j} {
	    set co [format {%11.2f} [expr [lindex $cutOffs $i]*10]]
	    set ClustNum [format {%11.2f} [expr $j+1]]
	    set Density  [format {%11.2f}  [expr 1.00*$clusters($i,$j)/($Totals($i)+1)]]
	    puts -nonewline $out $co
	    puts -nonewline $out $ClustNum
	    puts -nonewline $out $Density
	    puts $out ""
	}
    }
    close $out
}

## END PROCEDURES ##

## MAIN ##
proc main  {} {
    global clusters cutOffs
    foreach cutOff $cutOffs {
	set pathClust "cluster" 
	append pathClust $cutOff /cluster.dat 
	GetClust $pathClust [lsearch $cutOffs $cutOff] clusters
    }
     WriteClust clusters
}

#### RUN ##

main 
exit
