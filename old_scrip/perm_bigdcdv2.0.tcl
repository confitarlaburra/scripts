#script that count how many waters molecules permetates trough the NT

proc permeation { frame } {
  global upperEnd lowerEnd skipFrame wat segList ridList num1 num2 labelList nano 
  
  set out2 [open permeation.dat a+]
  molinfo top set frame $frame
  $nano frame $frame
  $nano update
  $wat frame $frame
  $wat update
  set nano_min_max [measure minmax $nano]
  set min_xyz [lindex $nano_min_max 0]
  set max_xyz [lindex $nano_min_max 1]
  
  set min_z [lindex $min_xyz 2]
  set max_z [lindex $max_xyz 2]
   
   
 
  set oldList $labelList
  set labelList {}
  set i 0
  foreach z [$wat get z] oldLab $oldList segname $segList resid $ridList {
      set nf [expr $frame-$skipFrame]
      if {$z > $max_z} {
      	set newLab 2
      if {$oldLab == -1} {
        puts "$segname:$resid permeated through the nanotubes along +z direction at frame $frame"
        if {$frame >= $skipFrame} { 
	    incr num1
            puts $out2 "$nf 1"
	    set i 1
        }
      }
    } elseif {$z < $min_z} {
      	set newLab -2
      	if {$oldLab == 1} {
        puts "$segname:$resid permeated through the nanotubes along -z direction at frame $frame"
        	if {$frame >= $skipFrame} {
          	incr num2
	   	puts $out2 "$nf -1"
	   	set i 1
        	}
      	}
    } elseif {abs($oldLab) > 1} {  
      	set newLab [expr $oldLab / 2]
    } else {
      	set newLab $oldLab
    }
    lappend labelList $newLab
  }
  

if {$frame >= $skipFrame} {
	if {$i == 0} {
	   puts $out2 "$nf 0"
	}
	set i 0
}

 
    
   set nf [expr $frame-$skipFrame]
   if {$nf >= 0 } {
   puts "The total number of permeation events during $nf frames in +z direction is: $num1"
   puts "The total number of permeation events during $nf frames in -z direction is: $num2"
   } else {
   puts "The specified first frame ($skipFrame) is larger than the total number of frames ($frame)"
   }

   close $out2
}

set input_psf nano_11_40_popc_water.psf
set input_dcd nano_11_40_popc_water_run_efz_cons_nvt.dcd
source /usr/local/lib/vmd/bigdcd/bigdcd.tcl
set skipFrame 1

mol load psf $input_psf
set nano [atomselect top "resname ARM"]
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
puts "Computing permeation events... (please wait)"
bigdcd permeation $input_dcd


