proc permeation { frame } {
	global oxygen_nt wat_nt cutoff angle nano
	set out [open h_bonds_water_nt.dat a+]
        
		
	puts "measuring h_bonds for frame $frame"
	
	$nano frame $frame
  	$nano update	
	set nano_min_max [measure minmax $nano]
  	set min_xyz [lindex $nano_min_max 0]
  	set max_xyz [lindex $nano_min_max 1]
  
  	set min_x [lindex $min_xyz 0]
  	set min_y [lindex $min_xyz 1]
  	set min_z [lindex $min_xyz 2]

  	set max_x [lindex $max_xyz 0]
  	set max_y [lindex $max_xyz 1]
  	set max_z [lindex $max_xyz 2]
    
	#set oxygen_nt [atomselect top "name OH2 and z > $min_z and z < $max_z and x > -2.7 and x < 2.7 and y > -2.7 and y < 2.7"]
	set oxygen_nt [atomselect top "name OH2 and z > $min_z and z < $max_z and x > $min_x and x < $max_x and y > $min_y and y < $max_y"]
    	set water_nt [$oxygen_nt get index]
    	set water_nt_number [llength $water_nt]
	set hbonds_list [measure hbonds $cutoff $angle $oxygen_nt]
	#set donors_index [lindex $hbonds_list 0]
	#set acceptors_index [lindex $hbonds_list 1]
	set hydrogens_index [lindex $hbonds_list 2]
	set hydrogens_index_length [llength $hydrogens_index]
	
   

    puts $out "$frame $hydrogens_index_length $water_nt_number"
    
    close $out
    
}


set input_psf "nano_5_40_popc_water.psf"
set input_dcd "nano_5_40_popc_water_run_01.dcd"
source bigdcd.tcl

mol load psf $input_psf

#h_bonds_parameters 
set nano [atomselect top "resname ARM"]
set cutoff   3.5
set angle    30

set nt [open h_bonds_water_nt.dat w]


bigdcd permeation $input_dcd






 
