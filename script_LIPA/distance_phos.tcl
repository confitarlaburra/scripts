proc distance_traj {frame} {
     global selection1 selection2
     set distance [distance top $selection1 $selection2]
     set out [open phos_dis.dat a+] 
     puts $out "$frame $distance"
     close $out
     if {$frame%100 == 0} {puts "$frame $distance"}
}


if { $argc != 3 } {
        puts "The distance_phos.tcl script requires 2 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/distance_phos.tcl -args path/to/inputpsf path/to/inputdcd"
        puts "Please try again."
        exit        
}



set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]    

mol load psf $input_psf
set selection1 "resname LIIV and name P4"
set selection2 "resname LIIV and name P7"
open phos_dis.dat w
source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/distance.tcl
bigdcd distance_traj $input_dcd

