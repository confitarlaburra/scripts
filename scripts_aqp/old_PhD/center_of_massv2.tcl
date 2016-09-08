proc hole { frame } {
global protein distance x_y
	
	if {$frame == 1} {
		set center [measure center $protein weight mass]
		set center_x_1 [lindex $center 0]
        	set center_y_1 [lindex $center 1]
		lappend x_y $center_x_1 
		lappend x_y $center_y_1 
	}
	
	puts "$frame"
	set center_x_1 [lindex $x_y 0]
        set center_y_1 [lindex $x_y 1]

	if {$frame > 1} {
#	puts "hola"
		set center [measure center $protein weight mass]
		set center_x [lindex $center 0]
        	set center_y [lindex $center 1]
		set distance [expr sqrt(($center_x - $center_x_1)*($center_x - $center_x_1) + ($center_y - $center_y_1)*($center_y - $center_y_1))]	
	}
	set out [open mass_displacement.out a+]
	puts $out "$frame $distance"

	set out2 [open x_y.out a+]
	if {$frame == 1} {
		puts $out2 "$frame $center_x_1 $center_y_1"
	} else {
		puts $out2 "$frame $center_x $center_y"	
	}
	close $out
	close $out2
}



set input_psf AQP_cw_pope_wi.psf 
set input_dcd ../AQP4_zero.dcd
open hole_c.out w
open mass_displacement.out w
open x_y.out w
set distance 0
set x_y {}
mol load psf $input_psf
set protein [atomselect top "protein and not water"]
source bigdcd.tcl
bigdcd hole $input_dcd
