
# Script to get a list of dihedrals in gromos format  of any molecules using VMD topo tools 
# Usage of proc dihedGRO : source it in vmd and " dihedGRO guess (guess or not dihed yes/no) out (output name of the list) 
# dihedType (gromos code for the dihed type) selection (molecule selection def all) mol (whic molecule in vmd def top)
# JAG 7.11.12 

proc dihedGRO { guess out  dihedType {selection all} {mol top}} {	
	set final_dihed_list {}
	set output [open $out w]
	set new_dihed {}
	set i 0
	if {$guess eq "yes"} {topo -sel $selection -molid $mol guessdihedrals}
	foreach dihed_list [topo -sel $selection -molid $mol getdihedrallist] {
		foreach index $dihed_list {
			if {$i > 0} {
				incr index				
				lappend new_dihed $index
			}
			incr i	
		}
		lappend final_dihed_list $new_dihed
		set i 0
		set new_dihed {}		
	}
	set $i 0
	puts $final_dihed_list
	foreach dihed $final_dihed_list {
		incr i
		foreach index $dihed {
			puts -nonewline $output [format "%7d" $index]
		}
		puts -nonewline $output [format "%6d" $dihedType]
		puts $output ""
		if {$i%10 eq 0 && $i < [llength $final_dihed_list]} {puts $output "# $i"}
	}
	set i 0
	close $output
	return $final_dihed_list	
}
	
## MAIN ##

dihedGRO yes dihe_list.dat 41 all top


