proc permeation { frame } {
	global  cutoff angle 
	set out [open h_bonds_water_nt.dat a+]
        
		
	puts "measuring h_bonds for frame $frame"
	
	foreach NT {A B C D} {
	
	set center [measure center [atomselect top "(chain $NT and resid 77 81 85 93 94 95 97 146 170 174 193 197 201 209 210 211 213 216) "]]
	
	set center_z [lindex $center 2]
	
	set center_x [lindex $center 0]
	
	set center_y [lindex $center 1]

	
	set max_x_$NT [expr $center_x + 2]
	set min_x_$NT [expr $center_x - 2]

	set max_y_$NT [expr $center_y + 2]
	set min_y_$NT [expr $center_y - 2]

	set max_z_$NT [expr $center_z + 12.5]
	set min_z_$NT [expr $center_z - 12.5]	
	 
		
  }
    
	
	set oxygen_A [atomselect top "name OH2 and z > $min_z_A and z < $max_z_A and x > $min_x_A and x < $max_x_A and y > $min_y_A and y < $max_y_A"]
    	set water_A [$oxygen_A get index]
    	set water_A_number [llength $water_A]
	set hbonds_list_A [measure hbonds $cutoff $angle $oxygen_A]
	set hydrogens_index_A [lindex $hbonds_list_A 2]
	set hydrogens_index_length_A [llength $hydrogens_index_A]

	set oxygen_B [atomselect top "name OH2 and z > $min_z_B and z < $max_z_B and x > $min_x_B and x < $max_x_B and y > $min_y_B and y < $max_y_B"]
    	set water_B [$oxygen_B get index]
    	set water_B_number [llength $water_B]
	set hbonds_list_B [measure hbonds $cutoff $angle $oxygen_B]
	set hydrogens_index_B [lindex $hbonds_list_B 2]
	set hydrogens_index_length_B [llength $hydrogens_index_B]

	set oxygen_C [atomselect top "name OH2 and z > $min_z_C and z < $max_z_C and x > $min_x_C and x < $max_x_C and y > $min_y_C and y < $max_y_C"]
    	set water_C [$oxygen_C get index]
    	set water_C_number [llength $water_C]
	set hbonds_list_C [measure hbonds $cutoff $angle $oxygen_C]
	set hydrogens_index_C [lindex $hbonds_list_C 2]
	set hydrogens_index_length_C [llength $hydrogens_index_C]

	set oxygen_D [atomselect top "name OH2 and z > $min_z_D and z < $max_z_D and x > $min_x_D and x < $max_x_D and y > $min_y_D and y < $max_y_D"]
    	set water_D [$oxygen_D get index]
    	set water_D_number [llength $water_A]
	set hbonds_list_D [measure hbonds $cutoff $angle $oxygen_D]
	set hydrogens_index_D [lindex $hbonds_list_D 2]
	set hydrogens_index_length_D [llength $hydrogens_index_D]
	
   

    puts $out "$frame $hydrogens_index_length_A $hydrogens_index_length_B $hydrogens_index_length_C $hydrogens_index_length_D $water_A_number $water_B_number $water_C_number $water_D_number "
    
    close $out
    
}


set input_psf "AQP_cw_pope_wi.psf"
set input_dcd "zero_20ns.dcd"
source bigdcd.tcl

mol load psf $input_psf

#h_bonds_parameters 

set cutoff   3.5
set angle    30

set nt [open h_bonds_water_nt.dat w]


bigdcd permeation $input_dcd
