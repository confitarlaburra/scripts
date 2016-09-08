## INPUT ##


#Input PSF
set psf          came.box.psf 
set reference_pdb came.box.pdb
set firstDCD     3
set lastDCD       4
set pathClust    /camefilteredwater/cluster0.20/
set bigdcd       ../../ana_scripts/bigdcd.tcl
set HbondCutoff   3.5
set HbondAngle    30
set steps 1
set selTextHbond "all and not carbon"
set NumClust 1
set selTextFit  "resname LIG and noh"

#inputs dcd (asumes that dcd start with "eq")
#it asumes all dcds part with eq (jag standard)
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    set dcd($i) "../eq$i.dcd"
}
set Clusters {}
for {set i 1} {$i <= $NumClust} {incr i} {
    lappend Clusters $i
}



#First frame to perform analyes
set first 1
#set array to be a global variable
set clustersTS(0) 0  
set clustersHbondTS(0,0) 0
set TotalHbonds(0) 0
set DonorsList {}
## END INPUT ##

## PROCEDURES ##

#Cluster procedure to get cluster number for cluster(gromo++ program) 
proc GetClust {ClusterFile &arrName} {
    upvar 1 ${&arrName} clusters
    set pattern_D  {\s*(\d+) \s*(\d+) \s*(\d+)}
    set inStream [open $ClusterFile r]
    set i 0
    set bool 0
    foreach line [split [read $inStream] \n] {
	if {[regexp $pattern_D $line match sub1 sub2 sub3]} { 
	    set clusters($i) $sub3
	    incr i
	}
    }
    close $inStream
}

proc Hbond {seltext angle cutoff cluster &arrName1 &arrName2 &ListName1 } {
    #global Variables
    upvar 1 ${&arrName1} clustersHbondTS
    upvar 1 ${&arrName2} TotalHbonds 
    upvar 1 ${&ListName1} DonorsList
    puts "Hbond"
    # Compute Hbonds for selection 
    set selection [atomselect top "$seltext"]
    set hbonds [measure hbonds  $cutoff $angle $selection]
    array set temp {}
    set TempDonorsList {}
    set i 0
    # loop over donor list and append in temp array
    foreach donor [lindex $hbonds 0] {
	puts $donor
	incr temp($donor)
	lappend TempDonorsList $donor
	incr i
    }
    #append for total habonds per cluster in time
    lappend TotalHbonds($cluster) $i 
    #append each hbond for each cluster
    foreach donor  [lsort -unique $TempDonorsList] {
	lappend clustersHbondTS($cluster,$donor) $temp($donor)
	lappend DonorsList $donor
    }
    
}


proc WriteFinal {&arrName1 &arrName2 &ListName1 &ListName2 } {
    #global Variables
    upvar 1 ${&arrName1} clustersHbondTS
    upvar 1 ${&arrName2} TotalHbonds
    upvar 1 ${&ListName1} DonorsList
    upvar 1 ${&ListName2} Clusters
    foreach cluster $Clusters {
	puts $cluster
	foreach donor $DonorsList {
	    puts "  $donor"
	    set sum 0
	    foreach event $clustersHbondTS($cluster,$donor) {
		puts "    $event"
	    }
	} 
    }
}


### Fit to referece frame (0)
proc FIT {selection } {
    set ref [atomselect top "$selection" frame 0]
    set sel [atomselect top "$selection"]
    set all [atomselect top all]
    $all move [measure fit $sel $ref]
} 


# Run analyses of defined descriptors

proc RunAna {seltext  angle cutoff cluster selTextFit} {
    puts "run ANA"
    global clustersHbondTS TotalHbonds DonorsList
    FIT $selTextFit
    Hbond $seltext $angle $cutoff 1 clustersHbondTS TotalHbonds DonorsList
}

proc RunBigDCD {frame } {
    global selTextHbond  HbondAngle HbondCutoff selTextFit
    puts "BigDCD"
    RunAna $selTextHbond  $HbondAngle $HbondCutoff 1 $selTextFit  
}

RunBigDCD 1
WriteFinal clustersHbondTS TotalHbonds DonorsList Clusters
## END PROCEDURES ##


#aca voy
## MAIN ##
proc main {&arrName} {
    upvar 1 ${&arrName} dcd 
    global psf reference_pdb numDCD bigdcd firstDCD lastDCD 
    global selTextFit selWrite pathClust clusters
    
    GetClust $pathClust clusters
#    mol load psf $psf
#    animate read pdb $reference_pdb
#    source $bigdcd
#    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
#    	bigdcd RunClust $dcd($i)
#    	bigdcd_wait
#    }
#}

#### RUN ##

#main dcd
#puts "finished with $steps frames!!!"



#clear array variables
foreach cluster $Clusters {
    unset TotalHbonds($cluster)
    foreach donor $DonorsList {
	unset clustersHbondTS($cluster,$donor)
    } 
}
#exit
