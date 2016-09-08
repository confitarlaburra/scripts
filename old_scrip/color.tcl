set input_psf "nano_6_40_popc_water.psf"
set input_dcd "n6.dcd"
set mixing_zone_size 4

mol load psf $input_psf
mol addfile $input_dcd waitfor all

set numFrame [molinfo top get numframes]
set nano [atomselect top "resname ARM"]

set water_up [atomselect top "water and z > 0" frame 0]
set water_down [atomselect top "water and z < 0" frame 0] 
$water_up set user 2
$water_down set user 5


for {set frame 1} {$frame < $numFrame} {incr frame} {
	
	$nano frame $frame
     	$nano update
	puts "frame $frame"

	set nano_min_max [measure minmax $nano]
	set nano_min_xyz [lindex $nano_min_max 0]
	set nano_max_xyz [lindex $nano_min_max 1]
	set nano_min_z [lindex $nano_min_xyz 2]
  	set nano_max_z [lindex $nano_max_xyz 2]

	set min_z [expr $nano_min_z - $mixing_zone_size] 
        set max_z [expr $nano_max_z + $mixing_zone_size]
	
        set old_frame [expr $frame -1]
 	set water_old [atomselect top "name OH2" frame $old_frame]
        set user_list [$water_old get user]
	#set old_z_list [$water_old get z]
	set water [atomselect top "name OH2" frame $frame]
        set indexList [$water get index]
          
       	foreach z [$water get z] user $user_list index $indexList   {
		  if { $z > $min_z  && $z < $max_z } {
		  	set water_mol [atomselect top "index $index" frame $frame]
			$water_mol set user $user
			$water_mol delete
                  } 	
		

	} 
	
        $water delete
        $water_old delete
	set black [atomselect top "water and z < $min_z" frame $frame]
	set white [atomselect top "water and z > $max_z" frame $frame]
	
	$black set user 5
        $white set user 2
	
	$black delete
        $white delete
}
