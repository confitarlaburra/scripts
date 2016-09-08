
## INPUT ##


#Input PSF
set psf          ../../ilagoDCA_ch.box.ion.psf
set reference_pdb ../../ilagoDCA_ch.box.ion.pdb
set firstDCD     3
set lastDCD      3
set bigdcd       ../../../ana_scripts/bigdcd.tcl
set HbondCutoff   3.5
set HbondAngle    30
set steps 1
#must be ligand or molecule of interest!!!!
set selTextHbond1 "resname LIG and oxygen"
#set to 0 for systems run in pyridine
set selTextHbond2 "water and oxygen"
set NumClust 1
set selTextFit  "resname LIG and noh"
set ClusterFile cluster_ts.dat
#inputs dcd (asumes that dcd start with "eq")
#it asumes all dcds part with eq (jag standard)
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    #set dcd($i) "../../eq$i.dcd"
    #when filtered 
    set dcd($i) "../../ilagoDCA_ch.2steps.dcd"
}



set  clustersNum(0) 0;  # Number of times each cluster is observed in trajectory
#First frame to perform analyes
#GetClustset first 1
#set array to be a global variable
set clustersNum(0) 0; # Number of times each cluster is observed in trajectory
set clustersTS(0) 0 ; # trajectory array  where each element is the coorespondig cluster (frame)
set clustersHbondTSD(0,0) 0 ; #first index (cluster,donor) 
set clustersHbondTSA(0,0) 0 ;  #first index (cluster,acceptor) 
set TotalHbonds(0) 0 ; # total Hbonds per cluster first index (cluster)
set DonorsList {} ; # Donors list observed in trajectory
set AcceptorsList {} ; # Acceptors list observed in trajectory
set Clusters {}

## END INPUT ##

## PROCEDURES ##

#Cluster procedure to get cluster number for cluster(gromo++ program) 
proc GetClust {ClusterFile &arrName1 &arrName2 } {
    upvar 1 ${&arrName1} clustersTS
    upvar 1 ${&arrName2} clustersNum 
    set pattern_D  {\s*(\d+) \s*(\d+) \s*(\d+)}
    set inStream [open $ClusterFile r]
    set i 1
    set bool 0
    foreach line [split [read $inStream] \n] {
	if {[regexp $pattern_D $line match sub1 sub2 sub3]} { 
	    set clustersTS($i) $sub3
	    incr clustersNum($sub3)
	    incr i
	}
    }
    close $inStream
}

proc Hbond { angle cutoff cluster &arrName1 &arrName2 &arrName3 &ListName1 &ListName2 seltext1 seltext2} {
    #global Variables
    upvar 1 ${&arrName1} clustersHbondTSD
    upvar 1 ${&arrName2} clustersHbondTSA
    upvar 1 ${&arrName3} TotalHbonds 
    upvar 1 ${&ListName1} DonorsList
    upvar 1 ${&ListName2} AcceptorsList
    # Compute Hbonds for selection
    set hbondsD {}
    set hbondsA {}
    set selection1 [atomselect top "$seltext1"]
    if {$seltext2 == 0} then {
	set hbondsD    [measure hbonds  $cutoff $angle $selection1]} else { 
	    set selection2 [atomselect top "$seltext2"]
	    set hbondsD    [measure hbonds  $cutoff $angle $selection1 $selection2]
	    set hbondsA    [measure hbonds  $cutoff $angle $selection2 $selection1]
	}
    array set tempD {}
    array set tempA {}
    set TempDonorsList {}
    set i 0
    # loop over donor list and append in temp array
    foreach donor [lindex $hbondsD 0] {
	incr tempD($donor)
	lappend TempDonorsList $donor
	incr i
    }
    #append for total hbonds per cluster in time
    
    #append each hbond for each cluster
    foreach donor  [lsort -unique $TempDonorsList] {
	lappend clustersHbondTSD($cluster,$donor) $tempD($donor)
	lappend DonorsList $donor
    }
    $selection1 delete
    if {$seltext2 != 0} {
	set TempAcceptorsList {}
	# loop over donor list and append in temp array
	foreach acceptor [lindex $hbondsA 1] {
	    incr tempA($acceptor)
	    lappend TempAcceptorsList $acceptor
	    incr i
	}
	
	#append each hbond for each cluster
	foreach acceptor  [lsort -unique $TempAcceptorsList] {
	    lappend clustersHbondTSA($cluster,$acceptor) $tempA($acceptor)
	    lappend AcceptorsList $acceptor
	}
	$selection2 delete
    }
    #append for total habonds per cluster in time
    lappend TotalHbonds($cluster) $i 

}


proc WriteFinal {&arrName1 &arrName2 &arrName3 &arrName4 &ListName1 &ListName2 &ListName3 } {
    #global Variables
    upvar 1 ${&arrName1}  clustersHbondTSD
    upvar 1 ${&arrName2}  clustersHbondTSA
    upvar 1 ${&arrName3}  TotalHbonds
    upvar 1 ${&arrName4}  clustersNum
    upvar 1 ${&ListName1} DonorsList
    upvar 1 ${&ListName2} AcceptorsList
    upvar 1 ${&ListName3} Clusters
    
    set out [open "HbondsClust.out" w]
    foreach cluster [lsort -unique $Clusters] {
	puts $out "#Cluster Number $cluster  $clustersNum($cluster)"
	set out2 [open "cluster.$cluster.TotalHbonds.out" w]
	puts $out2 "#Time         Hbonds"
	set i 0
	foreach hbond $TotalHbonds($cluster) {
	    incr i
	    puts $out2 [format {%9d%9d} $i $hbond]
	}
	close $out2
	foreach donor [lsort -unique $DonorsList] {
	    puts $out "    ##Donor Index  $donor"
	    set sum 0
	    if {[info exists clustersHbondTSD($cluster,$donor)]} { 
		foreach event $clustersHbondTSD($cluster,$donor) {
		    set sum [expr $sum + $event]
		}
	    }
	    set percentage [format {%0.3f} [expr (double($sum)/$clustersNum($cluster))*100]]
	    puts $out "            Percentage $percentage%"
	}

	foreach acceptor [lsort -unique $AcceptorsList] {
	    puts $out "    ##Acceptor Index  $acceptor"
	    set sum 0
	    if {[info exists clustersHbondTSA($cluster,$acceptor)]} { 
		foreach event $clustersHbondTSA($cluster,$acceptor) {
		    set sum [expr $sum + $event]
		}
	    }
	    set percentage [format {%0.3f} [expr (double($sum)/$clustersNum($cluster))*100]]
	    puts $out "            Percentage $percentage%"
	}
 
    }
    close $out
}




### Fit to referece frame (0)
proc FIT {selection } {
    set ref [atomselect top "$selection" frame 0]
    set sel [atomselect top "$selection"]
    set all [atomselect top all]
    $all move [measure fit $sel $ref]
} 



proc RunAna {frame} {
    #global for array  and list names
    global clustersHbondTSD clustersHbondTSA TotalHbonds DonorsList AcceptorsList clustersTS Clusters
    global selTextHbond1 selTextHbond2 HbondAngle HbondCutoff selTextFit 
    #FIT $selTextFit
    set cluster $clustersTS($frame)
    lappend Clusters $cluster
    Hbond  $HbondAngle $HbondCutoff $cluster clustersHbondTSD clustersHbondTSA TotalHbonds DonorsList AcceptorsList $selTextHbond1 $selTextHbond2
}



proc RunBigDCD {frame } {
    global steps	
    RunAna  $steps
    #puts $steps
    incr steps
}

## END PROCEDURES ##


## MAIN ##
proc main {&arrName1 } {
    upvar 1 ${&arrName1} dcd 
    global psf reference_pdb bigdcd ClusterFile firstDCD lastDCD 
    global Clusters clustersTS clustersNum TotalHbonds DonorsList AcceptorsList clustersHbondTSD clustersHbondTSA
    
    mol load psf $psf
    #animate read pdb $reference_pdb
    source $bigdcd
    
    GetClust  $ClusterFile clustersTS clustersNum
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    	bigdcd RunBigDCD $dcd($i)
    	bigdcd_wait 
    }

    WriteFinal clustersHbondTSD clustersHbondTSA TotalHbonds clustersNum DonorsList AcceptorsList Clusters
}

#### RUN ##

main dcd 
puts "finished!!!"
exit
