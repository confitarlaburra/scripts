proc water_load { frame } {
	global wat nano radius
	set WaterCounter 0	
	set out2 [open SPC_nt.dat a+]
		
	set nano_min_max [measure minmax $nano]
  	set min_xyz [lindex $nano_min_max 0]
  	set max_xyz [lindex $nano_min_max 1]
	set min_x [lindex $min_xyz 0]
	set max_x [lindex $max_xyz 0]
	set min_y [lindex $min_xyz 1]
        set max_y [lindex $max_xyz 1]
  	set min_z [lindex $min_xyz 2]
  	set max_z [lindex $max_xyz 2] 

	set nano_center [measure center $nano]
	set center_x [lindex $nano_center 0]
	set center_y [lindex $nano_center 1]
	
	foreach z [$wat get z] x [$wat get x] y [$wat get y] {
		if { $z > [expr $min_z -0.0]  && $z < [expr $max_z + 0.0] && $x > $min_x  && $x < $max_x && $y > $min_y  && $y < $max_y } { ;# Remove the plus and minus 2
			set delta_x  [expr $x - $center_x]
			set delta_y  [expr $y - $center_y]
			set distance [expr sqrt ($delta_x*$delta_x + $delta_y*$delta_y)]
			if {$distance <= $radius} {incr WaterCounter}
		}
	}
	set formatStr {%10d%10f}
	if {$frame % 500 == 0} {puts "mesuring frame $frame...."}	
	puts $out2 [format $formatStr "$frame" "$WaterCounter"]	 
	close $out2
}

####Main######

set pdb_name 01.pdb
set dcd_name  6.6_108CCL4.dcd
set radius 4.3
set formatStr {%10s%10s}
set out [open SPC_nt.dat w]
puts $out [format $formatStr "#Frame" "Pore Load"]
close $out
mol load pdb $pdb_name 
set wat [atomselect top "name OW"]
set nano [atomselect top "resname CCC"]
source  /home/fett/work/script/procedures/bigdcd.tcl
bigdcd water_load $dcd_name

