proc distance_traj {frame} {
    global selection1 selection2 selection3 selection4
    fit_bigdcd top "resname D193 and noh"
    set distanceA [distanceNOE top $selection1 $selection2]
    set distanceB [distanceNOE top $selection3 $selection4]
    set outA [open  H2_H11.dat  a+]
    set outB [open  H1_H10.dat  a+]
    puts $outA "$frame $distanceA"
    puts $outB "$frame $distanceB"
    if {$frame%100 == 0} {puts "$frame $distanceA"}
    close $outA
    close $outB
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

set selection1 "resname  D193 and name H2"
set selection2 "resname  D193 and name H11"

set selection3 "resname  D193 and name H1"
set selection4 "resname  D193 and name H10"
	   
open H2_H11.dat w
open H1_H10.dat w

source /home/fett/work/script/bigdcd.tcl
source /home/fett/work/script/procedures/fit_bigdcd.tcl
source /home/fett/work/script/procedures/distance.tcl

bigdcd distance_traj $input_dcd 
 
