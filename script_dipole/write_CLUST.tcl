## INPUT ##


#if { $argc != 7 } {
#        puts "The write_CLUST.tcl script requires 7 variables  to be inputed."
#        puts "For example, vmd -dispdev text -e path/to/write_clust.tcl -args path/to/inputpsf  path/to/reference_pdb DCD  path/clujst/file path/to/bigdcd"
#        puts "Please try again."
#        exit        
#}



#Input PSF
set psf           [lindex $argv 0]
set reference_pdb [lindex $argv 1]
set DCD           [lindex $argv 2]
set pathClust     [lindex $argv 3]
set bigdcd        [lindex $argv 4]
set SolvCutoff    [lindex $argv 5]

set steps 0
puts "este esl el DCD $DCD"
#inputs dcd (asumes that dcd start with "eq")
#it asumes all dcds part with eq (jag standard)
#for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
#    set dcd($i) "../eq$i.dcd"
#}



set selTextFit  "protein and name CA"
set selWrite    "all"

#First frame to perform analyes
set first 1
#set array to be a global variable
array set clusters {}
## END INPUT ##

## PROCEDURES ##

#Cluster procedure to get cluster number for cluster(gromo++ program) 
proc GetClust {ClusterFile &arrName} {
    upvar 1 ${&arrName} clusters
    set pattern_A  {CLUSTER}
    set pattern_B  {CLUSTER\S+}
    set pattern_C  {(END)}
    set pattern_D  {\s*(\d+) \s*(\d+)}
    set inStream [open $ClusterFile r]
    set i 0
    set bool 0
    foreach line [split [read $inStream] \n] {
	if {[regexp $pattern_A $line]} {set bool 1}
	if {[regexp $pattern_B $line]} {set bool 0}
	if {[regexp $pattern_C $line]} {set bool 0}
	if {$bool == 1} {
	    if {[regexp $pattern_D $line match sub1 sub2]} { #element zero is not a cluster
		set clusters($i) $sub2
		incr i
	    }
	}
    }
    close $inStream
}

## Writes a pdb ###
proc WriteClust {selWrite cluster steps SolvCutoff} {
    set all [atomselect top "$selWrite"]
    $all writepdb 0$cluster.$steps.$SolvCutoff.pdb
}

### Fit to referece frame (0)
proc FIT {selection } {
    set ref [atomselect top "$selection" frame 0]
    set sel [atomselect top "$selection"]
    set all [atomselect top all]
    $all move [measure fit $sel $ref]
} 


# Run analyses of defined descriptors

proc RunAna {steps selTextFit selWrite &arrName SolvCutoff  } {
    upvar 1 ${&arrName} clusters
    set size [array size clusters]
    # element zero is not a cluster
    for {set i 1} {$i < $size} {incr i} {
	if {$steps == $clusters($i)} {
	    puts "writing cluster $i of frame $steps"
	    FIT $selTextFit
	    WriteClust $selWrite $i $steps $SolvCutoff
	}
    }
}

# Procedure to be run with bigdcd
proc RunClust {frame} {
    global steps selTextFit selWrite clusters SolvCutoff
    RunAna $steps $selTextFit $selWrite clusters $SolvCutoff
    incr steps
}

## END PROCEDURES ##

## MAIN ##
proc main  {} {
    global psf reference_pdb numDCD bigdcd DCD 
    global selTextFit selWrite pathClust clusters
    GetClust $pathClust clusters
    mol load pdb $psf
    animate read pdb $reference_pdb
    source $bigdcd
    bigdcd RunClust $DCD
    bigdcd_wait
}

#### RUN ##

main 
puts "finished with $steps frames!!!"
exit
