proc distance_traj {frame} {
     global selection1 selection2
     set distance [ distanceFirst top $selection1 $selection2]
     set out [open COM_dis_126.dat  a+] 
     puts $out "$frame $distance"
     if {$frame%100 == 0} {puts "$frame $distance"}
     close $out
}

if { $argc != 4 } {
        puts "The COM_dis.tcl script requires 3 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/Com_dis.tcl -args path/to/inputpsf path/to/inputdcd path/to/reference_pdb"
        puts "Please try again."
        exit        
}


set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]
set reference_pdb [lindex $argv 2]

mol load psf $input_psf
animate read pdb $reference_pdb

set selection1 "protein"
set selection2 "protein and resid 126"
open COM_dis_126.dat w
source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/distance.tcl
bigdcd distance_traj $input_dcd
