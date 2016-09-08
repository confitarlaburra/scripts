#
# Script computes order parameters  P1 =    <cos(theta)> 
# theta is the angle between the bilayer normal directed along z 
# and the unit dipole moment of water
 

proc orientation {frame} {
     global qH qO numframes name1  nano  all radius
          	
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
	#puts hola 	
     #
     # select waters to be included in P1 and P2 calc. and binned in histogram
     #
     set wat [atomselect top "resname SOLV and ( same residue as (( name OW) and ((($min_x < x) and (x < $max_x) and (  $min_y < y) and (y < $max_y)) and z > $min_z and z < $max_z  )))"]

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
		set p1 0		
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
				# compute P1 and accumulate
				set mudotn    [ expr [ lindex $mu 2 ] / $mun ]
				set p1        [ expr $p1 + $mudotn     ]
			}					
		}
		set p1 [expr $p1/([llength $idwat]/3)]
		set out1 [open $name1 a+]
		if {$frame <= $numframes} {puts $out1 [format  "%10.3f%10.3f" "$frame" "$p1"]}
		close $out1
		if {$frame % 500 == 0} {puts "mesuring frame $frame...."}			
	}
	
		
	
}

set input_pdb 01.pdb 
set input_dcd trajectory.dcd
set numframes 5000
#
# TIP3P charges of O and H and number of slices 
#
set qH      0.410 
set qO     -0.820
set radius 3.0

#
# open file pointer in write append mode (so one does not overwrite old data)
#

set name1 "orientation.dat"
set out [open $name1 w]
puts $out [format "%10s %10s" "#Frame" "<cos(theta)>"]
close $out

mol load pdb $input_pdb
set nano [atomselect top "resname CCC"]
set all [atomselect top all]


source /home/jgarate/script/bigdcd.tcl
bigdcd orientation $input_dcd
