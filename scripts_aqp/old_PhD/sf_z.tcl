proc permeation { frame } {
	global numframes	
	foreach chain {A B C D}  {
		global sf_$chain pore_$chain list_$chain 	
	}	
  
	set z_A1 [$sf_A get z]
    	set z_B1 [$sf_B get z]
	set z_C1 [$sf_C get z]
	set z_D1 [$sf_D get z]
	
	set x_A1 [$sf_A get x]
    	set x_B1 [$sf_B get x]
	set x_C1 [$sf_C get x]
	set x_D1 [$sf_D get x]

	set y_A1 [$sf_A get y]
    	set y_B1 [$sf_B get y]
	set y_C1 [$sf_C get y]
	set y_D1 [$sf_D get y]
	
	set z_A2 [$pore_A get z]
    	set z_B2 [$pore_B get z]
	set z_C2 [$pore_C get z]
	set z_D2 [$pore_D get z]

	set x_A2 [$pore_A get x]
    	set x_B2 [$pore_B get x]
	set x_C2 [$pore_C get x]
	set x_D2 [$pore_D get x]         
		
	set y_A2 [$pore_A get y]
    	set y_B2 [$pore_B get y]
	set y_C2 [$pore_C get y]
	set y_D2 [$pore_D get y] 
	
	set distance_A [expr sqrt (($x_A1 - $x_A2)*($x_A1 - $x_A2) + ($y_A1 - $y_A2)*($y_A1 - $y_A2) + ($z_A1 - $z_A2)*($z_A1 - $z_A2))]

	set distance_B [expr sqrt (($x_B1 - $x_B2)*($x_B1 - $x_B2) + ($y_B1 - $y_B2)*($y_B1 - $y_B2) + ($z_B1 - $z_B2)*($z_B1 - $z_B2))]

	set distance_C [expr sqrt (($x_C1 - $x_C2)*($x_C1 - $x_C2) + ($y_C1 - $y_C2)*($y_C1 - $y_C2) + ($z_C1 - $z_C2)*($z_C1 - $z_C2))]

	set distance_D [expr sqrt (($x_D1 - $x_D2)*($x_D1 - $x_D2) + ($y_D1 - $y_D2)*($y_D1 - $y_D2) + ($z_D1 - $z_D2)*($z_D1 - $z_D2))]	

	lappend  list_A $distance_A
	lappend  list_B $distance_B
	lappend  list_C $distance_C
	lappend  list_D $distance_D	
	
	if {$frame == $numframes} {
		set result 0
		set n 0
		foreach distance $list_A {
			set result [expr $result + $distance]
			incr n
		}
		set average_A [expr $result/$n]
		set result 0
		set n 0
		foreach distance $list_B {
			set result [expr $result + $distance]
			incr n
		}
		set average_B [expr $result/$n]
		set result 0
		set n 0
		foreach distance $list_B {
			set result [expr $result + $distance]
			incr n
		}
		set average_B [expr $result/$n]
		set result 0
		set n 0
		foreach distance $list_C {
			set result [expr $result + $distance]
			incr n
		}
		set average_C [expr $result/$n]
		set result 0
		set n 0
		foreach distance $list_D {
			set result [expr $result + $distance]
			incr n
		}
		set average_D [expr $result/$n]
		
		set out3 [open average_distance.out a+ ]
		puts $out3 "$average_A $average_B $average_C $average_D"
		close $out3

	} 	 

	 	 

        set out  [open sf_z.out a+]
	set out2 [open distance.out a+]
	
	puts $out  "$frame $z_A1 $z_B1 $z_C1 $z_D1"
	puts $out2 "$frame $distance_A $distance_B $distance_C $distance_D"
	if {$frame % 100 == 0} {
		puts "$frame $distance_A $distance_B $distance_C $distance_D"
	}    
	close $out
	close $out2    
}


set input_psf ../AQP_cw_pope_wi.psf
set input_dcd ../AQP4_zero.dcd
set numframes 100806 

mol load psf $input_psf
set sf_A [atomselect top "index 40643"]
set sf_B [atomselect top "index 44179"]
set sf_C [atomselect top "index 47715"]
set sf_D [atomselect top "index 51251"]

set pore_A [atomselect top "index 40861"]
set pore_B [atomselect top "index 44397"]
set pore_C [atomselect top "index 47933"]
set pore_D [atomselect top "index 51469"]

foreach chain {A B C D} {
	set list_$chain {}
}

open sf_z.out w
open distance.out w
open average_distance.out w
source bigdcd.tcl

bigdcd permeation $input_dcd






 
