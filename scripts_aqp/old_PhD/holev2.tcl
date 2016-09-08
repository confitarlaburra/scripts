proc hole { frame } {
global num_frame z_list chain ref sel all minimal_radio_list all

for {set t 1} {$t <= 250} {incr t} {
              	set t_list $t
		global $t_list
        }
puts $frame
#get the coordinates of a monomer 	
	$all move [measure fit $sel $ref]
	set center [measure center [atomselect top "chain $chain and name CA"]]
                
        set center_x [lindex $center 0]
        set center_y [lindex $center 1]
        set center_z [lindex $center 2]

	set pore [atomselect top "chain $chain"]
	$pore writepdb pore_fit.pdb
	$pore delete
	#$pdb_out delete
	
	set out [open pore.inp w]
	puts $out "COORD pore_fit.pdb \nRADIUS amberuni.rad\nCPOINT $center_x  $center_y  $center_z\nCVECT 0 0 1\nENDRAD 8 \nSHORTO 1"
	#puts $out "COORD pore_fit.pdb \nRADIUS amberuni.rad\nENDRAD 8\nSHORTO 1"
	close $out
	exec ./hole < pore.inp > pore.out 
	file delete pore_fit.pdb
	#obtain the radius from hole output file

	set i -1
	set radius_list {}
	set in [open pore.out r]
	foreach line [split [read $in] \n] { 
		if {[string equal [string range $line 0 11] " cenxyz.cvec" ]} {
			set i 0
		}
		if {$i >= 0 && $i <= 250} { 
			set radius [string trim [string range $line 14 24]]
			lappend radius_list $radius
			
			if {$frame == 1 && $i >= 1 && $i <= 250 } {
				set z [string trim [string range $line 0 13]]
				lappend z_list $z			
			} 
			incr i				
		}
	}
	set x 1000
	for {set t 1} {$t <= 250} {incr t} {
		set t_list $t
		#set $t_list {}
		set radi [lindex $radius_list $t ]
		if {$radi < $x} {
			set x $radi
		}
		#lappend $t_list [lindex $radius_list $t ]
		lappend $t_list $radi	
		
	}
	lappend  minimal_radio_list $x
	#file delete pore.inp
	#file delete pore.out
	#puts [subst $250]
	#puts $z_list

	if { $frame == $num_frame} {

		set result 0
		set n 0
		foreach min $minimal_radio_list {
			set result [expr $result +$min]
			incr n
		}
		set min_average [expr $result/$n]
		#puts $min_average
		set result 0
		foreach min $minimal_radio_list {
			set result [expr $result + ($min - $min_average)*($min - $min_average)]
		}
		set sd_min [expr sqrt($result/$n)]
		set out_2 [open min_rad_av_d.out a+]
		puts $out_2 "$min_average $sd_min"
		close $out_2
		
		set average_list {}
		set sd_list {}
		for {set j 1} {$j <= 250} {incr j} {
			#set t_list $j
			set result 0 
			set n 0
			foreach radio [subst $$j] {				
				set result [expr $result + $radio]
				incr n
			}
			set average [expr $result/$n]
			lappend average_list $average
			set result 0
			
			foreach radio [subst $$j] {
				set result [expr $result + ($radio - $average)*($radio - $average)]
			}
			set sd [expr sqrt ($result/$n)]
 			lappend sd_list $sd	 
		}
		set out  [open hole_d.out a+]
		foreach z $z_list a $average_list s $sd_list {
			set z [expr $z*-1]	
			puts $out "$a $z $s"
		}
		close $out 
		
	}


display update ui 
}



set input_psf AQP_cw_pope_wi.psf 
set input_dcd zero_1000.dcd
set num_frame "1000"
set chain "D"
for {set t 1} {$t <= 250} {incr t} {
                set t_list $t
                set $t_list {}
}
set z_list {}
open hole_d.out w
open min_rad_av_d.out w
mol load psf $input_psf
set all [atomselect top all]
set ref [atomselect top "chain $chain and name CA" frame 0]
set sel [atomselect top "chain $chain and name CA"]
set minimal_radio_list {}
animate read pdb AQP_cw_pope_wi.pdb
source bigdcd.tcl
bigdcd hole $input_dcd
