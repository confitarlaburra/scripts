proc permeation { frame } {
  
   

  puts "frame $frame"

  
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
  set half_y [expr ($min_y_1 + $max_y_1)/2] 
# Display settings
  display eyesep       0.065000
  display focallength  2.000000
  display height       6.000000
  display distance     -2.000000
  display projection   Perspective
  display nearclip set 0.500000
  display farclip  set 10.000000
  display depthcue   off
  display cuestart   0.500000
  display cueend     10.000000
  display cuedensity 0.400000
  display cuemode    Exp2
  axes location off
  color Display Background white
#nanotube 1 
  mol modselect   0 top segid NT1 and y < 12
  mol modstyle    0 top surf 2.600000 0.000000 
  mol modcolor    0 top colorid 6
  mol modmaterial 0 top Diffuse
#water inside nt1
  mol addrep top
  mol modselect   1 top water and x > 7.82 and y > 8.08 and x < 17.17 and y < 17.17 and z > -20  and z < 20
  mol modstyle    1 top surf 2.600000 0.000000
  mol modcolor    1 top colorid 23
  mol modmaterial 1 top Transparent
#nanotube 2 
  mol addrep top
  mol modselect   2 top segid NT2 
  mol modstyle    2 top surf 2.600000 0.000000 
  mol modcolor    2 top colorid 6
  mol modmaterial 2 top Diffuse	  
#nanotube 3
  mol addrep top
  mol modselect   3 top segid NT3 
  mol modstyle    3 top licorice 0.100000 50.000000 50.000000 
  mol modcolor    3 top colorid 6
  mol modmaterial 3 top Diffuse	
#water inside nt3
  mol addrep top
  mol modselect   4 top water and x < -7.82 and y > 8.08 and x > -17.17 and y < 17.17 and z >  -19.5  and z < 19.5
  mol modstyle    4 top VDW 1.000000 99.000000
  mol modcolor    4 top colorid 22
  mol modmaterial 4 top Diffuse
#nanotube 4 
  mol addrep top
  mol modselect   5 top segid NT4 
  mol modstyle    5 top surf 2.600000 0.000000 
  mol modcolor    5 top colorid 6
  mol modmaterial 5 top Diffuse	
#water
 # mol addrep top
  #mol modselect   6 top water and (z < -18 or  water and z >18) and y < $half_y
  #mol modstyle    6 top surf 2.600000 0.000000
  #mol modcolor    6 top colorid 23
  #mol modmaterial 6 top Transparent
#lipids
  #mol addrep top
  #mol modselect   7 top lipid and noh and y < 13
  #mol modstyle    7 top VDW 1.000000 99.000000
  #mol modcolor    7 top colorid 23
  #mol modmaterial 7 top Diffuse

  set viewpoints([molinfo top]) {{{1.000000 0.000000 0.000000 0.102333} {0.000000 1.000000 0.000000 -0.557842} {0.000000 0.000000 1.000000 -0.009207} {0.000000 0.000000 0.000000 1.000000}} {{-0.800639 0.525221 -0.288363 0.000000} {-0.411084 -0.131368 0.902092 0.000000} {0.435905 0.840778 0.321088 0.000000} {0.000000 0.000000 0.000000 1.000000}} {{0.028233 0.000000 0.000000 0.000000} {0.000000 0.028233 0.000000 0.000000} {0.000000 0.000000 0.028233 0.000000} {0.000000 0.000000 0.000000 1.000000}} {{1.000000 0.000000 0.000000 0.230000} {0.000000 1.000000 0.000000 0.040000} {0.000000 0.000000 1.000000 0.000000} {0.000000 0.000000 0.000000 1.000000}}}
  lappend viewplist [molinfo top]
  set topmol [molinfo top]
# done with molecule 0
  foreach v $viewplist {
     molinfo $v set {center_matrix rotate_matrix scale_matrix global_matrix} $viewpoints($v)
  }

  if {$frame <= 9 } {
     render Tachyon 000$frame.dat
     exec /usr/local/lib/vmd/tachyon_LINUXAMD64 -res 256 256 -auto_skylight 1.3 000$frame.dat -o 000$frame.tga
     exec convert 000$frame.tga  000$frame.jpg
     exec rm 000$frame.dat 000$frame.tga
  }  

  if { $frame >= 10 && $frame <= 99 } {
     render Tachyon 00$frame.dat
     exec /usr/local/lib/vmd/tachyon_LINUXAMD64 -auto_skylight 1.3 00$frame.dat -o 00$frame.tga
     exec convert 00$frame.tga  00$frame.jpg
     exec rm 00$frame.dat 00$frame.tga
  }
  
  if { $frame >= 100 && $frame <= 999 } {
     render Tachyon 0$frame.dat
     exec /usr/local/lib/vmd/tachyon_LINUXAMD64  -auto_skylight 1.3 0$frame.dat -o 0$frame.tga
     exec convert 0$frame.tga  0$frame.jpg
     exec rm 0$frame.dat 0$frame.tga
  }

  if { $frame >= 1000 && $frame <= 9999 } {
     render Tachyon 0$frame.dat
     exec /usr/local/lib/vmd/tachyon_LINUXAMD64  -auto_skylight 1.3 0$frame.dat -o 0$frame.tga
     exec convert 0$frame.tga  0$frame.jpg
     exec rm 0$frame.dat 0$frame.tga
  }

    foreach i {0 1 2 3 4 5 6 7} {
	
	mol delrep $i top
		
 }
}


set input_psf "n6.pdb.tet.popc.water.psf"
set input_dcd "n6_video.dcd" 
mol load psf $input_psf 
set all [atomselect top all]

source bigdcd.tcl
bigdcd permeation $input_dcd
