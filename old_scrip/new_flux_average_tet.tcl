proc permeation { frame } {
  foreach NT {1 2 3 4} {
	      global total_up_down_1_$NT total_down_up_1_$NT total_up_down_2_$NT total_down_up_2_$NT total_list_1_$NT total_list_2_$NT 
  } 
   
  global all wat segList ridList labelList nanos z_list mixing_zone_size num_frames average_interval 
  
  set oldList $labelList
  set labelList {}
  set old_zlist $z_list
  set z_list [$wat get z]
   
  set lab_1 0
  set lab_2 0

  $nanos frame $frame
  $nanos update

  $wat frame $wat
  $wat update
  puts "analysing frame $frame"

#gets the coordinates of the NTs and defines the mixing zone z coordinates  
  
  set nano_min_max [measure minmax $nanos]
  set nano_min_xyz [lindex $nano_min_max 0]
  set nano_max_xyz [lindex $nano_min_max 1]
  
  
  set nano_min_z [lindex $nano_min_xyz 2]
  set nano_max_z [lindex $nano_max_xyz 2]

  set min_z [expr $nano_min_z - $mixing_zone_size] 
  set max_z [expr $nano_max_z + $mixing_zone_size]
  
#gets the minmax coordinates for each NT
  foreach NT {1 2 3 4} {
	
	set min_max [measure minmax [atomselect top "segid NT$NT" ] ]
	set min_xyz [lindex $min_max 0]
	set max_xyz [lindex $min_max 1]
	
	set min_x_$NT [lindex $min_xyz 0]
	set max_x_$NT [lindex $max_xyz 0]
	
	set min_y_$NT [lindex $min_xyz 1]
	set max_y_$NT [lindex $max_xyz 1]
		
  }
    #puts $min_x_1
#sets initial conditions, waters above the center are labeled as 1 (white) 
#waters under the center are labeled as 2 (black) 

  if {$frame == 1} {
      set center [measure center $all]
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
  

#Counts the amount of 1 and 2 water molecules, values save in output file total_amount_1_2.dat
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
#values save in output file total_flux_1_2.dat
   set center [measure center $all]
   set center_z [lindex $center 2]
   
   foreach z [$wat get z] x [$wat get x] y [$wat get y] z_old $old_zlist oldLab $oldList lab $labelList {
           if { $lab == $oldLab && $z > $min_z && $z < $max_z } {	
					    
			     if {$lab == 1} {
					 if {$z < $center_z && $z_old > $center_z && $x > $min_x_1 && $x < $max_x_1  && $y > $min_y_1 && $y < $max_y_1} {
						 incr total_up_down_1_1
					 }
					 if {$z < $center_z && $z_old > $center_z && $x > $min_x_2 && $x < $max_x_2  && $y > $min_y_2 && $y < $max_y_2} {
						 incr total_up_down_1_2
					 }
					 if {$z < $center_z && $z_old > $center_z && $x > $min_x_3 && $x < $max_x_3  && $y > $min_y_3 && $y < $max_y_3} {
						 incr total_up_down_1_3
					 }
					 if {$z < $center_z && $z_old > $center_z && $x > $min_x_4 && $x < $max_x_4  && $y > $min_y_4 && $y < $max_y_4} {
						 incr total_up_down_1_4
					 }
					 if {$z > $center_z && $z_old < $center_z && $x > $min_x_1 && $x < $max_x_1  && $y > $min_y_1 && $y < $max_y_1} {
						 incr total_down_up_1_1
					 }
					 if {$z > $center_z && $z_old < $center_z && $x > $min_x_2 && $x < $max_x_2  && $y > $min_y_2 && $y < $max_y_2} {
						 incr total_down_up_1_2
					 }
					 if {$z > $center_z && $z_old < $center_z && $x > $min_x_3 && $x < $max_x_3  && $y > $min_y_3 && $y < $max_y_3} {
						 incr total_down_up_1_3
					 }
					 if {$z > $center_z && $z_old < $center_z && $x > $min_x_4 && $x < $max_x_4  && $y > $min_y_4 && $y < $max_y_4} {
						 incr total_down_up_1_4
					 }
				 }
				 if {$lab == 2} {
					 if {$z < $center_z && $z_old > $center_z && $x > $min_x_1 && $x < $max_x_1  && $y > $min_y_1 && $y < $max_y_1} {
  						incr total_up_down_2_1
					 }	
					 if {$z < $center_z && $z_old > $center_z && $x > $min_x_2 && $x < $max_x_2  && $y > $min_y_2 && $y < $max_y_2} {
  						incr total_up_down_2_2
					 }
					 if {$z < $center_z && $z_old > $center_z && $x > $min_x_3 && $x < $max_x_3  && $y > $min_y_3 && $y < $max_y_3} {
  						incr total_up_down_2_3
					 }
					 if {$z < $center_z && $z_old > $center_z && $x > $min_x_4 && $x < $max_x_4  && $y > $min_y_4 && $y < $max_y_4} {
  						incr total_up_down_2_4
					 }
					 if {$z > $center_z && $z_old < $center_z && $x > $min_x_1 && $x < $max_x_1  && $y > $min_y_1 && $y < $max_y_1} {
						incr total_down_up_2_1 
					 }
					 if {$z > $center_z && $z_old < $center_z && $x > $min_x_2 && $x < $max_x_2  && $y > $min_y_2 && $y < $max_y_2} {
						incr total_down_up_2_2 
					 }
					 if {$z > $center_z && $z_old < $center_z && $x > $min_x_3 && $x < $max_x_3  && $y > $min_y_3 && $y < $max_y_3} {
						incr total_down_up_2_3 
					 }
					 if {$z > $center_z && $z_old < $center_z && $x > $min_x_4 && $x < $max_x_4  && $y > $min_y_4 && $y < $max_y_4} {
						incr total_down_up_2_4 
					 }
				 }
	       }
	
   }

 

  	set total_1_1 [expr $total_up_down_1_1 - $total_down_up_1_1]
  	set total_1_2 [expr $total_up_down_1_2 - $total_down_up_1_2]
  	set total_1_3 [expr $total_up_down_1_3 - $total_down_up_1_3]
  	set total_1_4 [expr $total_up_down_1_4 - $total_down_up_1_4]

  	set total_2_1 [expr $total_down_up_2_1 - $total_up_down_2_1]
  	set total_2_2 [expr $total_down_up_2_2 - $total_up_down_2_2]
  	set total_2_3 [expr $total_down_up_2_3 - $total_up_down_2_3]
  	set total_2_4 [expr $total_down_up_2_4 - $total_up_down_2_4]
  
  	set total_flux_1 [open total_flux_1 a+]
  	puts $total_flux_1 "$frame $total_1_1 $total_2_1"
    #puts "$total_1_1 $total_2_1"
  	close $total_flux_1
  
  	set total_flux_2 [open total_flux_2 a+]
  	puts $total_flux_2 "$frame $total_1_2 $total_2_2"
  	close $total_flux_2

  	set total_flux_3 [open total_flux_3 a+]
  	puts $total_flux_3 "$frame $total_1_3 $total_2_3"
  	close $total_flux_3

  	set total_flux_4 [open total_flux_4 a+]
  	puts $total_flux_4 "$frame $total_1_4 $total_2_4"
  	close $total_flux_4
  
	if { $frame % $average_interval == 0  && $frame >= $average_interval } {
     	lappend total_list_1_1 $total_1_1
        lappend total_list_1_2 $total_1_2
  		lappend total_list_1_3 $total_1_3
		lappend total_list_1_4 $total_1_4
		
		lappend total_list_2_1 $total_2_1
		lappend total_list_2_2 $total_2_2   
		lappend total_list_2_3 $total_2_3
		lappend total_list_2_4 $total_2_4                                                                                                                                               
  	}
    
  	if {$frame == $num_frames} {
	    set nano_seconds [expr $average_interval*0.001]
		foreach  NT {1 2 3 4} {
				   set average_list_$NT {}
		}
	
		
#average flux for NT1
		for { set i 1} { $i < [llength $total_list_1_1] } {incr i} {
		          set j [expr $i -1]
		          set tot_1 [lindex $total_list_1_1 $j]
		          set tot_2 [lindex $total_list_1_1 $i]
		          set average [expr ($tot_2 -$tot_1)/$nano_seconds]
		          lappend  average_list_1  $average
		}
	

  		for { set i 1} { $i < [llength $total_list_2_1] } {incr i} {
		          set j [expr $i -1]
		          set tot_1 [lindex $total_list_2_1 $j]
		          set tot_2 [lindex $total_list_2_1 $i]
		          set average [expr ($tot_2 -$tot_1)/$nano_seconds]
		          lappend  average_list_1  $average
		}
  		set result 0
	        set n [llength $average_list_1]
	        set n_se [expr $n*($n - 1)]
	 
	    foreach average $average_list_1 {
		  		set result [expr $result + $average]		
	    }
	    set big_average [expr $result/$n]

		set result 0
	    foreach average $average_list_1 {
		  		set result [expr $result + ($average - $big_average)*($average - $big_average)]
	    }
	    set se [expr sqrt ($result/$n_se)]
	    set average_flux  [open average_flux_1 a+]
	    puts $average_flux "average flux = $big_average se = $se"
	    close $average_flux
	
#average flux for NT2
		for { set i 1} { $i < [llength $total_list_1_2] } {incr i} {
		          set j [expr $i -1]
		          set tot_1 [lindex $total_list_1_2 $j]
		          set tot_2 [lindex $total_list_1_2 $i]
		          set average [expr ($tot_2 -$tot_1)/$nano_seconds]
		          lappend  average_list_2  $average
		}


  		for { set i 1} { $i < [llength $total_list_2_2] } {incr i} {
		          set j [expr $i -1]
		          set tot_1 [lindex $total_list_2_2 $j]
		          set tot_2 [lindex $total_list_2_2 $i]
		          set average [expr ($tot_2 -$tot_1)/$nano_seconds]
		          lappend  average_list_2  $average
		}
  		set result 0
	    set n [llength $average_list_2]
	    set n_se [expr $n*($n - 1)]

	    foreach average $average_list_2 {
		  		set result [expr $result + $average]		
	    }
	    set big_average [expr $result/$n]

		set result 0
	    foreach average $average_list_2 {
		  		set result [expr $result + ($average - $big_average)*($average - $big_average)]
	    }
	    set se [expr sqrt ($result/$n_se)]
	    set average_flux  [open average_flux_2 a+]
	    puts $average_flux "average flux = $big_average se = $se"
	    close $average_flux
#average flux for NT 3
		for { set i 1} { $i < [llength $total_list_1_3] } {incr i} {
			      set j [expr $i -1]
			      set tot_1 [lindex $total_list_1_3 $j]
			      set tot_2 [lindex $total_list_1_3 $i]
			      set average [expr ($tot_2 -$tot_1)/$nano_seconds]
			      lappend  average_list_3  $average
		}


		for { set i 1} { $i < [llength $total_list_2_3] } {incr i} {
				  set j [expr $i -1]
				  set tot_1 [lindex $total_list_2_3 $j]
				  set tot_2 [lindex $total_list_2_3 $i]
				  set average [expr ($tot_2 -$tot_1)/$nano_seconds]
				  lappend  average_list_3  $average
		}
	    set result 0
	    set n [llength $average_list_3]
	    set n_se [expr $n*($n - 1)]

		foreach average $average_list_3 {
				set result [expr $result + $average]		
		}
	    set big_average [expr $result/$n]

		set result 0
		foreach average $average_list_3 {
				set result [expr $result + ($average - $big_average)*($average - $big_average)]
	    }
	    set se [expr sqrt ($result/$n_se)]
	    set average_flux  [open average_flux_3 a+]
	    puts $average_flux "average flux = $big_average se = $se"
	    close $average_flux	

#average flux for NT 4
		for { set i 1} { $i < [llength $total_list_1_4] } {incr i} {
				  set j [expr $i -1]
				  set tot_1 [lindex $total_list_1_4 $j]
				  set tot_2 [lindex $total_list_1_4 $i]
				  set average [expr ($tot_2 -$tot_1)/$nano_seconds]
				  lappend  average_list_4  $average
		}


		for { set i 1} { $i < [llength $total_list_2_4] } {incr i} {
				  set j [expr $i -1]
				  set tot_1 [lindex $total_list_2_4 $j]
				  set tot_2 [lindex $total_list_2_4 $i]
				  set average [expr ($tot_2 -$tot_1)/$nano_seconds]
				  lappend  average_list_4  $average
		}
		set result 0
	    set n [llength $average_list_4]
		set n_se [expr $n*($n - 1)]

		foreach average $average_list_4 {
				set result [expr $result + $average]		
		}
		set big_average [expr $result/$n]

		set result 0
		foreach average $average_list_4 {
				set result [expr $result + ($average - $big_average)*($average - $big_average)]
		}
	    set se [expr sqrt ($result/$n_se)]
		set average_flux  [open average_flux_4 a+]
		puts $average_flux "average flux = $big_average se = $se"
		close $average_flux	
	}
    	
   }
}


set input_psf "n6.pdb.tet.popc.water.psf"
set input_dcd "nano_6_40_popc_water_tet_run_01.dcd"
set mixing_zone_size 4
set num_frames 30000
set average_interval 5000
mol load psf $input_psf 
set all [atomselect top all]
set nanos [atomselect top "resname ARM"]
set wat [atomselect top "name OH2"]
set z_list [$wat get z]
set segList [$wat get segname]
set ridList [$wat get resid]  
set labelList {}
foreach foo $segList {
        lappend labelList 0
}
foreach NT {1 2 3 4} {
	    set total_up_down_1_$NT 0
        set total_down_up_1_$NT 0
        set total_up_down_2_$NT 0
        set total_down_up_2_$NT 0
        set total_list_1_$NT {}
        set total_list_2_$NT {}
        set total_flux_$NT [open total_flux_$NT w]
        set average_flux_$NT [open average_flux_$NT w]
}
source bigdcd.tcl
bigdcd permeation $input_dcd
