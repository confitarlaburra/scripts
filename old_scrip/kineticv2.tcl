set input_psf "nano_5_40_popc_water.psf"
set input_dcd "nano_5_40_popc_water_run_short_01.dcd"
set input_dcd_vel "velocity.dcd"
#set kb 1.3806504e-23
#set amu 1.660538782e-27
set out [open temp_rot.dat  w]

mol load psf $input_psf
set nano [atomselect 0 "resname ARM"]

mol addfile $input_dcd waitfor all
set numFrame [molinfo top get numframes]

mol load psf $input_psf
mol addfile $input_dcd_vel waitfor all

for {set fr 0} {$fr < $numFrame} {incr fr} {
	 puts $fr
	 $nano frame $fr
     $nano update
     #obtains the nt minmax coordinates for each frame
     set nano_min_max [measure minmax $nano]
     set min_xyz [lindex $nano_min_max 0]
     set max_xyz [lindex $nano_min_max 1]
  
     set min_x [lindex $min_xyz 0]
     set min_y [lindex $min_xyz 1]
     set min_z [lindex $min_xyz 2]

     set max_x [lindex $max_xyz 0]
     set max_y [lindex $max_xyz 1]
     set max_z [lindex $max_xyz 2]
     #obtains the waters molecules located inside the nt for each frame
     set wat_nt [atomselect 0 "name OH2 and z > $min_z and z < $max_z and x > $min_x and x < $max_x and y > $min_y and y < $max_y" frame $fr]
     set seglist [$wat_nt get segid]
     set reslist [$wat_nt get resid]
     set ktrans 0
     set ktot 0
     set nw_in_nt 0
     #loop for each water molecule inside the nt
     foreach segid $seglist resid $reslist {
	         set water [atomselect 1 "same residue as (segid $segid and resid $resid)" frame $fr ]
	         set velocity_cm [measure center $water weight mass]
	         #velocities in m/s, 2045.482706 (value to convert velocites into m/s)
	         set vcmx [expr 2045.482706*[lindex $velocity_cm 0]]
	         set vcmy [expr 2045.482706*[lindex $velocity_cm 1]]
	         set vcmz [expr 2045.482706*[lindex $velocity_cm 2]]
	         #translational kinetic energy in kg*m**2*s**-2 for water molecules inside the nt
	         set ktrans [expr $ktrans + 9.0075e-3*( ($vcmx*$vcmx) + ($vcmy*$vcmy) + ($vcmz*$vcmz) ) ] 
		     incr nw_in_nt
		     set water_index [$water get index]
		     #loop for each water atom inside the nt
		     foreach index $water_index {
			         set single_atom [atomselect 1 "index $index" frame $fr]
			         #mass in kg
			         set mass_mol [$single_atom get mass]
			         set mass [expr $mass_mol*0.001]
			         #velocities in m/s, 2045.482706 (value to convert velocites into m/s)
			         set velx [expr 2045.482706*[$single_atom get x]]
			  		 set vely [expr 2045.482706*[$single_atom get y]]
			         set velz [expr 2045.482706*[$single_atom get z]]
			         #total kinetic energy in kg*m**2*s**-2 for water atoms inside the nt
			         set ktot [expr $ktot + 0.5*$mass*( ($velx*$velx) + ($vely*$vely) + ($velz*$velz) )]
			         
		     }
		  
	 }
	#set nc [expr 4 + 3*$nw_in_nt]
	#set temp_tot [expr 2*$ktot/((9*$nw_in_nt - $nc)*$kb)]
	#set temp_trans [expr 2*$ktrans/((3*$nw_in_nt - 4)*$kb)]
	#set temp_rot [expr $temp_tot - $temp_trans]
	set ktot [expr $ktot*0.001]
	set ktrans [expr $ktrans*0.001]
	set krot [expr $ktot - $ktrans]
	puts $out "$fr $ktot $ktrans $krot $nw_in_nt"
	
	
        
}
close $out
exit

