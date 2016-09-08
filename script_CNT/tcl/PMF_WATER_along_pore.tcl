#
# Script computes PMF along tube axix (bases of oxygens positions
# Pore needs to be aligned in z axis
 

proc orientation {frame} {
     global  nslices  pore numframes name1  p1 end icntO slWidth nano inv_width radius Kb T
   
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
     # select waters to be included in P1 and P2 calc. and binned in histogram
     #
     set wat [atomselect top "name OW and ( $min_x < x and x < $max_x and $min_y < y and y < $max_y and z > $min_z and z < $max_z)"]	
 
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
     if { [llength $idwat] !=0 } {
	 for {set j 0} {$j < [llength $idwat] } {incr j}  {		
	     set rO  [ lindex $coord $j ]
	     set x [lindex $rO 0]
	     set y [lindex $rO 1]			
	     set delta_x  [expr $x - $center_x]
	     set delta_y  [expr $y - $center_y]
	     set distance [expr sqrt ($delta_x*$delta_x + $delta_y*$delta_y)]
	     if {$distance <= $radius} { 
		 #
		 # determine slices for pore axis
		 #
		 
		 set zO    [ expr abs( [ lindex $rO  2 ] - $max_z ) ]
		
		 ### always change this value accroding to the slice width 
		 set sli   [ expr $zO*5] ; ### always change this value accroding to the slice width
		 set sli   [ expr int($sli) ]
		 #
		 # bin into histograms
		 #
			set icntO($sli)   [ expr $icntO($sli)   + 1 ]
				
	     }
	 }
		   
     }		
	 		   			   	   	
	
	if {$frame == $numframes} {
		set out1 [open $name1 a+]
		for {set id 0} {$id  < $nslices} {incr id} {
       			set ztemp [ expr double($id)         ]
       			set ztemp [ expr ($ztemp*$slWidth)/10   ]; #nanometers
			if { $icntO($id) != 0 } {
				set icntO($id) [expr $icntO($id) +0.0]
           			set icntO($id) [ expr $icntO($id)/$numframes ]; #nanometers
				set PMF [expr -$Kb*$T*log($icntO($id))]
			}
			set formatstring "%10.5f%10.5f%10.5f"
			puts $out1 [format $formatstring "$PMF"  "$ztemp" "$icntO($id)"]	
    		}
	              
    		close $out1
	}
	if {$frame % 1000 == 0} {
		puts "measuring $frame...."
	}
}

set input_pdb ../01.pdb
set input_dcd ../trajectory.dcd
set numframes 40000

#bins sizes and width
set nslices  70
set slWidth 0.2
set inv_width [expr 1.0/$slWidth]
set radius 4.0
set T  298
set Kb 0.00831441


#
# zero arrays histograms, and counters
#
for {set id 0} {$id  <= $nslices} {incr id} {
    set icntO($id) 0
}

#
# open file pointer in write append mode (so one does not overwrite old data)
#

set name1 "PMF_along_pore.dat"
set out [open  $name1 w]
set formatstring "%10s%10s%10s"
puts $out [format $formatstring "#PMF" "PoreAxis" "Prob"]
close $out


mol load pdb $input_pdb
set nano [atomselect top "resname CCC"]

source /home/jgarate/script/bigdcd.tcl
bigdcd orientation $input_dcd
