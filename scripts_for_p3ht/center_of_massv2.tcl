proc center { frame } {
global P3T rod_z gold_z Cl
	

	set center [measure center $P3T weight mass]
	#set center [measure center $P3T]
	set center_x [lindex $center 0]
        set center_y [lindex $center 1]
	set center_z [lindex $center 2]
	#set center_z [expr $center_z*20.45482706]	
	set center_cl [measure center $Cl]
	set center_z_cl [lindex $center_cl 2]	

	if {$frame < 2001} {
		set distance_rod [expr $center_z - $rod_z]
		set distance_gold [expr $center_z - $gold_z]
		set distance_cl [expr $center_z - $center_z_cl]		

		
		set out1 [open center_of_mass.out a+]
		set out2 [open distance_rod.out a+]
		set out3 [open distance_gold.out a+]
		set out4 [open distance_cl.out a+]
		puts $out1 "$frame $center_z"
		puts $out2 "$frame $distance_rod"
		puts $out3 "$frame $distance_gold"
		puts $out4 "$frame $distance_cl"
		close $out1
		close $out2
		close $out3
		close $out4

	}
	if {$frame % 10 == 0} {
		puts $center_z
	} 
}



set input_psf tol_1.2_4_rod_100_P3HT_50x50x160.psf
set input_dcd eq2.dcd
set rod_z -52.625
set gold_z -75.321
open center_of_mass.out w
open distance_rod.out w
open distance_gold.out w
open distance_cl.out w
mol load psf $input_psf
set P3T [atomselect top "resname P3T"]
set Cl [atomselect top "resname CLA"]
source bigdcd.tcl
bigdcd center $input_dcd
