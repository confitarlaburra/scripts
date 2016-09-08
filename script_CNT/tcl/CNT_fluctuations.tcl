#
# Script computes order parameters  P1 =    <cos(theta)> 
# and                               P2 = 0.5<3*cos(theta)^2-1> 
# theta is the angle between the bilayer normal directed along z 
# and the unit dipole moment of water
 

proc orientation {frame} {
     global  nslices  pore numframes name1  p1 end icntO slWidth nano inv_width
   
	# min max of the selection
        set nano_min_max [measure minmax $nano]
  	set min_xyz [lindex $nano_min_max 0]
  	set max_xyz [lindex $nano_min_max 1]
  
  	set min_x [lindex $min_xyz 0]
  	set min_y [lindex $min_xyz 1]
  	set min_z [lindex $min_xyz 2]

  	set max_x [lindex $max_xyz 0]
  	set max_y [lindex $max_xyz 1]
  	set max_z [lindex $max_xyz 2]
	
	set center   [measure center $nano]
	set center_x [lindex $center 0]
	set center_y [lindex $center 1] 
     #
     # get list of atoms, their coordinates 
     #
     set idnano [$nano list]
     set coord [$nano get {x y z}]
     #
     #
     # if waters are selected then compute....
     #
     if { [llength $idnano] !=0 && $frame >= 0} {
	    	for {set j 0} {$j < [llength $idnano] } {incr j} {
		
		
                	set rO  [ lindex $coord $j ]

			#
			# determine slices for mu (same as for O) and for H1 and H1
			#
			set zO    [ expr abs( [ lindex $rO  2 ] - $max_z ) ]
			### always change this value accroding to the slice width 
			set sli   [ expr $zO*0.5] ; ### always change this value accroding to the slice widt
                	set sli   [ expr int($sli) ]
                	#
			# compute the collective distance for each bin
			#

			set xO [lindex $rO 0]
			set yO [lindex $rO 1]
			set delta_x [expr ($xO - $center_x)]
			set delta_y [expr ($yO - $center_y)]
			
			
			set distance_xy [expr sqrt($delta_x*$delta_x + $delta_y*$delta_y)]
			set p1($sli)    [ expr $p1($sli) + $distance_xy ]
                  	
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
       			set ztemp [ expr ($ztemp*$slWidth)/10   ]; #nanometers
			if { $icntO($id) != 0 } {
           			set p1($id) [ expr ($p1($id) / $icntO($id))/10 ]; #nanometers
			}
			set formatstring "%10.5f%10.5f"
			puts $out1 [format $formatstring "$p1($id)" "$ztemp"]	
    		}
	              
    		close $out1
	

	}
	if {$frame % 1000 == 0} {
		puts "measuring $frame...."
	}
}

set input_pdb ../01.pdb
set input_dcd ../trajectory.dcd
set numframes 8000

#bins sizes and width
set nslices  7
set slWidth 2.0
set inv_width [expr 1.0/$slWidth]



#
# zero arrays to contain order params, histograms, and counters
#

for {set id 0} {$id  <= $nslices} {incr id} {
    set p1($id)    0
    set icntO($id) 0

}

#
# open file pointer in write append mode (so one does not overwrite old data)
#

set name1 "CNT_distances_XY_5ns.dat"
set out [open  $name1 w]
set formatstring "%7s%7s"
puts $out [format $formatstring "#AvgDist" "PoreAxis"]
close $out


mol load pdb $input_pdb
set nano [atomselect top "resname CCC"]

source /home/jgarate/script/bigdcd.tcl
bigdcd orientation $input_dcd
