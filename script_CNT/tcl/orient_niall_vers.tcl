#
# Script computes order parameters  P1 =    <cos(theta)> 
# and                               P2 = 0.5<3*cos(theta)^2-1> 
# theta is the angle between the bilayer normal directed along z 
# and the unit dipole moment of water
# for a carbon nanotube 

proc orientation {frame} {
     global qH qO nslices  nano numframes name1  p1 p2 range org end icntO slWidth radius
     
	set nano_min_max [measure minmax $nano]
  	set min_xyz [lindex $nano_min_max 0]
  	set max_xyz [lindex $nano_min_max 1]
  
  	set min_x [lindex $min_xyz 0]
  	set min_y [lindex $min_xyz 1]
  	set min_z [lindex $min_xyz 2]

  	set max_x [lindex $max_xyz 0]
  	set max_y [lindex $max_xyz 1]
  	set max_z [lindex $max_xyz 2]

	
	set nano_center [measure center $nano]
	set center_x [lindex $nano_center 0]
	set center_y [lindex $nano_center 1]
     

     #
     # select waters to be included in P1 and P2 calc. and binned in histogram
     #
     set wat [atomselect top "resname H2O and ( same residue as (( name OW) and ((($min_x < x) and (x < $max_x) and (  $min_y < y) and (y < $max_y)) and z > $min_z and z < $max_z  )))"]

     #
     # get list of atoms, their coordinates 
     #
     set idwat [$wat list]
     set coord [$wat get {x y z}]
     # delete selection 
     #
     $wat delete
     #
     # if waters are selected then compute....
     #
     if { [llength $idwat] !=0 && $frame >= 0} {
	    	for {set j 0} {$j < [expr [llength $idwat] / 3 ]} {incr j} {
		
			set k [expr $j *3]
			set x [lindex [lindex $coord [expr $k + 0]] 0]
			set y [lindex [lindex $coord [expr $k + 0]] 1]			
			set delta_x  [expr $x - $center_x]
			set delta_y  [expr $y - $center_y]
			set distance [expr sqrt ($delta_x*$delta_x + $delta_y*$delta_y)]
			if {$distance <= $radius} {
                		set rO  [ lindex $coord [expr $k + 0] ] 
                		set rH1 [ lindex $coord [expr $k + 1] ]
                		set rH2 [ lindex $coord [expr $k + 2] ]
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
			}                  	
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
			puts $out1 [format "%10s %10s %10s" "$ztemp" "$p1($id)" "$p2($id)"]	
    		}
	              
    		close $out1
	

	}
	if {$frame % 100 == 0} {
		puts $frame
	}
}

set input_pdb ../01.pdb 
set input_dcd ../trajectory.dcd
set numframes 10000
#
# TIP3P charges of O and H and number of slices 
#
set qH      0.410 
set qO     -0.820
set radius 4.0



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

set name1 "orientation.dat"
set out [open $name1 w]
puts $out [format "%10s %10s %10s" "#Poreaxis" "<P1>" "<P2>"]
close $out

mol load pdb $input_pdb
set nano [atomselect top "resname CCC"]
set all [atomselect top all]


source /home/jgarate/script/bigdcd.tcl
bigdcd orientation $input_dcd

