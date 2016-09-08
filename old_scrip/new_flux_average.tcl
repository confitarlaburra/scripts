proc permeation { frame } {
  global wat segList ridList labelList nano z_list total_up_down_1 total_down_up_1 total_up_down_2 total_down_up_2  mixing_zone_size num_frames average_interval total_1_list total_2_list
  
 
  
  set oldList $labelList
  set labelList {}
  set old_zlist $z_list
  set z_list [$wat get z]
   
  set lab_1 0
  set lab_2 0

  $nano frame $frame
  $nano update

  $wat frame $wat
  $wat update
  puts "analysing frame $frame"
#gets the coordinates of the NT and defines the mixing zone z coordinates  
  
  set nano_min_max [measure minmax $nano]
  set nano_min_xyz [lindex $nano_min_max 0]
  set nano_max_xyz [lindex $nano_min_max 1]
  
  set nano_min_x [lindex $nano_min_xyz 0]
  set nano_max_x [lindex $nano_max_xyz 0]
   
  set nano_min_y [lindex $nano_min_xyz 1]
  set nano_max_y [lindex $nano_max_xyz 1]
  
  set nano_min_z [lindex $nano_min_xyz 2]
  set nano_max_z [lindex $nano_max_xyz 2]

  set min_z [expr $nano_min_z - $mixing_zone_size] 
  set max_z [expr $nano_max_z + $mixing_zone_size]

#sets initial conditions, waters above the center are labeled as 1 (white) 
#waters under the center are labeled as 2 (white) 

  if {$frame == 1} {
      set center [measure center $nano]
      set center_z [lindex $center 2]
      foreach z [$wat get z] oldLab $oldList segname $segList resid $ridList {
            if {$z > $center_z} {
		set newlab 1
            } else {
	        set newlab 2
            }
      	    lappend labelList $newlab
     }

  }

  
   if {$frame > 1} {

# sets the 1 (white) and 2 (black) reservoirs for all the frames, starting from the second frame
# and keeps the old label for the water molecules in the mixing zone

     foreach z [$wat get z] oldLab $oldList {
             if {$z > $max_z}  {                                           
                set newlab 1
              } elseif {$z < $min_z } {                                   
              	set newlab 2 	                           
              } else {
		set newlab $oldLab
              }

             lappend labelList $newlab              
     }
   }

#Counts the amount of 1 and 2 water molecules, values saved in output file total_amount_1_2.dat
   foreach lab $labelList {
	   if {$lab == 1 } {
              incr lab_1
            } else {
              incr lab_2
            }
   }

   set total_amount_1_2 [open total_amount_1_2.dat a+]
   puts $total_amount_1_2 "$frame $lab_1 $lab_2"
   close $total_amount_1_2
   
#Counts how many 1 and 2 water molecules are moving up and down from the center line 
#values saved in output file total_flux_1_2.dat
   set center [measure center $nano]
   set center_z [lindex $center 2]
   foreach z [$wat get z] z_old $old_zlist oldLab $oldList lab $labelList {
           if { $lab == $oldLab && $z > $min_z && $z < $max_z } {	
				
				if {$lab == 1} {
					if {$z < $center_z && $z_old > $center_z} {
						incr total_up_down_1
					}
					if {$z > $center_z && $z_old < $center_z} {
						incr total_down_up_1
					} 
				}
				if { $lab == 2} {
					if {$z < $center_z && $z_old > $center_z} {
						
  						incr total_up_down_2
					}
					if {$z > $center_z && $z_old < $center_z} {
						
						incr total_down_up_2 
					}
					
				}
	}
	
   }

 

  set total_1 [expr $total_up_down_1 - $total_down_up_1]
  set total_2 [expr $total_down_up_2 - $total_up_down_2]	  
  set total_flux_1_2 [open total_flux_1_2 a+]
  puts $total_flux_1_2 "$frame $total_1 $total_2"
  close $total_flux_1_2
    if { $frame % $average_interval == 0  && $frame >= 5000 } {	
      lappend  total_1_list  $total_1
      lappend  total_2_list  $total_2
     # puts $total_1_list
     # puts $total_2_list
  }
  if {$frame == $num_frames} {
      set nano_seconds [expr $average_interval*0.001]
      set average_list {}
      
      for { set i 1} { $i < [llength $total_1_list] } {incr i} {
	  set j [expr $i -1]
	  set tot_1 [lindex $total_1_list $j] 
	  set tot_2 [lindex $total_1_list $i]
	  set average [expr ($tot_2 -$tot_1)/$nano_seconds]
	  lappend  average_list  $average
	               
		   }
      #puts $average_list
      for { set i 1} { $i < [llength $total_2_list] } {incr i} {
	  set j [expr $i -1]
	  set tot_1 [lindex $total_2_list $j]
	  set tot_2 [lindex $total_2_list $i]
	  set average [expr ($tot_2 -$tot_1)/$nano_seconds]
	  lappend  average_list  $average
                   }
      #puts $average_list
      set result 0
      set n [llength $average_list]
      set n_se [expr $n*($n - 1)] 
      foreach average $average_list {
	  set result [expr $result + $average]		
      }
      set big_average [expr $result/$n]
	
	set result 0
      foreach average $average_list {
	  set result [expr $result + ($average - $big_average)*($average - $big_average)]
      }
      set se [expr sqrt ($result/$n_se)]
      set average_flux  [open average_flux a+]
      puts $average_flux "average flux = $big_average se = $se"
      close $average_flux
  }
}


set input_psf "nano_8_40_popc_water.psf"
set input_dcd "nano_8_40_popc_water_run_efy_variant.dcd"
set mixing_zone_size 4
set num_frames 20000
set average_interval 1
mol load psf $input_psf 
set nano [atomselect top "resname ARM"]
set wat [atomselect top "name OH2"]
set segList [$wat get segname]
set ridList [$wat get resid]
set z_list [$wat get z]  
set labelList {}
set total_1_list {}                                                                                                                                                    
set total_2_list {}
foreach foo $segList {
        lappend labelList 0
}

set total_amount_1_2 [open total_amount_1_2.dat w]
set total_flux_1_2 [open total_flux_1_2 w]
set average_flux   [open average_flux w]
set total_up_down_1 0
set total_down_up_1 0
set total_up_down_2 0
set total_down_up_2 0
source /usr/local/lib/vmd/bigdcd/bigdcd.tcl
bigdcd permeation $input_dcd
