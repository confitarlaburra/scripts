#script that count how many waters molecules permetates trough the NT

proc permeation { frame } {
  global   skipFrame wat segList ridList num1 num2 labelList protein numframes protein min_z max_z
  
  set out2 [open permeation.dat a+]
  
  set min_z_old $min_z
  set max_z_old $max_z
  if { $frame % 1 == 0} {
  	set nano_min_max [measure minmax $protein]
  	set min_xyz [lindex $nano_min_max 0]
  	set max_xyz [lindex $nano_min_max 1]
  
  	set min_z [lindex $min_xyz 2]
  	set max_z [lindex $max_xyz 2]
  } else {
	set min_z $min_z_old
	set max_z $max_z_old
  }
  
   
 
  set oldList $labelList
  set labelList {}
  foreach z [$wat get z] oldLab $oldList segname $segList resid $ridList {
      	if {$z > $max_z} {
      		set newLab 2
       		if {$oldLab == -1} {
        		if {$frame >= $skipFrame} { 
	    			incr num1
        		}
      		}
    	} elseif {$z < $min_z} {
      		set newLab -2
      		if {$oldLab == 1} {
        		if {$frame >= $skipFrame} {
          			incr num2
        		}
      		}
    	} elseif {abs($oldLab) > 1} {  
      		set newLab [expr $oldLab / 2]
    	} else {
      		set newLab $oldLab
    	}
    	lappend labelList $newLab
  }
  set total [expr $num1 + $num2] 
  set nf [expr $frame - $skipFrame]
  if {$frame % 100 == 0 } {  	
	puts "$frame $num1 $num2"
  }
  if {$frame >= $skipFrame} {
	puts $out2 "$nf $num1 $num2 $total"

  }
	
    if {$frame == $numframes} {
	puts "The total number of permeation events during $nf frames in +z direction is: $num1"
	puts "The total number of permeation events during $nf frames in -z direction is: $num2"
    }
	close $out2	
}


set input_psf ../AQP_cw_pope_wi.psf 
set input_dcd ../AQP4_zero.dcd
set numframes 100806
set skipFrame 5000
mol load psf $input_psf
set min_z 0
set max_z 0
set protein [atomselect top "protein and resid 216 93"]
set wat [atomselect top "name OH2"]
set segList [$wat get segname]
set ridList [$wat get resid]
set labelList {}
set num1 0
set num2 0  
  foreach foo $segList {
  lappend labelList 0
  }
set out [open permeation.dat w]
source bigdcd.tcl
bigdcd permeation $input_dcd


