proc distance_traj {frame} {
     global selection1 CA_list nelements
     set total 0
     foreach index $CA_list {
             set selection2 "index $index"
	     set distance   [distance top $selection1 $selection2]
	     set total [expr $distance + $total]
     }
     set average [expr $total/$nelements]
     set out [open CA_com_average.dat  a+] 
     puts $out "$frame $average"
     if {$frame%100 == 0} {puts "$frame $average"}
     close $out
}


if { $argc != 3 } {
        puts "The CA_COM.tcl script requires 3 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/CA_COM.tcl -args path/to/inputpsf path/to/inputdcd"
        puts "Please try again."
        exit        
}


set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]
mol load psf $input_psf
set selection1 "segid TLR4 and name CA"
set sel [atomselect top "segid TLR4 and name CA"]
set CA_list   [$sel get index]
set nelements [llength $CA_list] 
open CA_com_average.dat w
source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/distance.tcl
bigdcd distance_traj $input_dcd
