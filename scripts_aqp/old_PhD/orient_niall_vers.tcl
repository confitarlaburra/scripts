#
# Script computes order parameters  P1 =    <cos(theta)> 
# and                               P2 = 0.5<3*cos(theta)^2-1> 
# theta is the angle between the bilayer normal directed along z 
# and the unit dipole moment of water
 

proc orientation {frame} {
     global qH qO nslices  pore numframes name1  p1 p2 range org end icntO slWidth
     
     set center_pore [measure center $pore]
     set pore_x [lindex $center_pore 0]
     set pore_y [lindex $center_pore 1]	
     set min_x  [expr $pore_x - $range]
     set min_y  [expr $pore_y - $range]
     set max_x  [expr $pore_x + $range]
     set max_y  [expr $pore_y + $range]
    
     set min_z [$org get z]
     set max_z [$end get z]	
     

     #
     # select waters to be included in P1 and P2 calc. and binned in histogram
     #
     set wat [atomselect top "water and ( same residue as (( name OH2) and ((($min_x < x) and (x < $max_x) and (  $min_y < y) and (y < $max_y)) and z > $min_z and z < $max_z  )))"]

     #
     # get list of atoms, their coordinates 
     #
     set idwat [$wat list]
     set coord [$wat get {x y z}]
     #puts [llength $idwat]
     # delete selection 
     #
     $wat delete
     #
     # if waters are selected then compute....
     #
     if { [llength $idwat] !=0 && $frame >= 0} {
	    	for {set j 0} {$j < [expr [llength $idwat] / 3 ]} {incr j} {
		
			set k [expr $j *3]
		
                	set rO  [ lindex $coord [expr $k + 0] ] 
                	set rH1 [ lindex $coord [expr $k + 1] ]
                	set rH2 [ lindex $coord [expr $k + 2] ]
			#puts "$rO"
			set mu  [ vecadd [vecscale $qO $rO]  [vecscale $qH $rH1] [vecscale $qH $rH2] ]
			set mun [ veclength $mu ]

			#
			# determine slices for mu (same as for O) and for H1 and H1
			#

			set zO    [ expr abs( [ lindex $rO  2 ] - $max_z ) ]
			set sli   [ expr $zO*10] 
                	set sli   [ expr int($sli) ]
			#puts $sli
                	#
			# compute P1 and P2 and accumulate
			#

			set mudotn    [ expr [ lindex $mu 2 ] / $mun ]
			set mudotn2   [ expr $mudotn * $mudotn       ]
			set 3mudotn1  [ expr ( 3 * $mudotn2 ) - 1    ]
			set p1($sli)  [ expr $p1($sli) + $mudotn     ]
			set p2($sli)  [ expr $p2($sli) + $3mudotn1   ]
                  	
			#
			# bin into histograms
			#
			set icntO($sli)   [ expr $icntO($sli)   + 1 ]
					

		}
	}	
	
	if {$frame == $numframes} {
		set out1 [open $name1 a+]
		for {set id 0} {$id  < $nslices} {incr id} {
       			set ztemp [ expr double($id)         ]
       			set ztemp [ expr $ztemp*$slWidth   ]

			if { $icntO($id) != 0 } {
           			set p1($id) [ expr $p1($id) / $icntO($id) ]
           			set p2($id) [ expr 0.5 * $p2($id) / $icntO($id) ]
			}
			puts $out1 "$ztemp $p1($id) $p2($id)"	
    		}
	              
    		close $out1
	

	}
	if {$frame % 100 == 0} {
		puts $frame
	}
}

set input_psf ../AQP_cw_pope_wi.psf
set input_dcd ../AQP4_zero.dcd
set numframes 100806
set chain "A"
set range 3.5
#
# TIP3P charges of O and H and number of slices 
#
set qH      0.417 
set qO     -0.834
set nslices  250
set slWidth 0.1



#
# zero arrays to contain order params, histograms, and counters
#

for {set id 0} {$id  < $nslices} {incr id} {
    set p1($id)    0
    set p2($id)    0
    set icntO($id) 0

}

#
# open file pointer in write append mode (so one does not overwrite old data)
#

set name1 "$chain.p1_p2.2.0.dat.test.20_5"
open $name1 w



mol load psf $input_psf

if {$chain eq "A"} {
	set pore [atomselect top "index 40643 40256 39054 40861"]
	set org [atomselect top "index 39054"]
        set end [atomselect top "index 40643"]
} elseif {$chain eq "B"} {
	set pore [atomselect top "index 44179 44397 43792 42590"]
	set org [atomselect top "index 42590"]
	set end [atomselect top "index 44179"]
} elseif {$chain eq "C"} {
	set pore [atomselect top "index 47715 47933 47328 46126"]
	set org [atomselect top "index 46126"]
	set end [atomselect top "index 47715"]	
} else {
	set pore [atomselect top "index 51251 51469 50864 49662"]
	set org [atomselect top "index 49662"]
	set end [atomselect top "index 51251"]
}

source bigdcd.tcl
bigdcd orientation $input_dcd
