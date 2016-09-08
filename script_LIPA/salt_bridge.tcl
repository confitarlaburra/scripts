#!/usr/bin/tclsh
proc salt {frame} {
    global cutoff
    fit_bigdcd top "protein"
    foreach positive {ARG LYS} {
	foreach phos {P4 P7} {
	    Saltbrdige top $positive "resname D193 and name $phos" $cutoff $positive.$phos
	}
    }
    
    if {$frame % 100 == 0} { puts $frame }
}


if { $argc != 5 } {
    puts "The salt_bridge.tcl script requires 4 variables  to be inputed."
    puts "For example, vmd -dispdev text -e path/to/salt_bridge.tcl path/to/inputpsf path/to/inputdcd path/to/reference_pdb cutoff"
    puts "Please try again."
    exit        
}

set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]
set reference_pdb [lindex $argv 2] 
set cutoff [lindex $argv 3]


mol load psf $input_psf

animate read pdb $reference_pdb


source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/fit_bigdcd.tcl
source /home/jgarate/script/procedures/salt_bridge.tcl

foreach positive {ARG LYS} {
    foreach phos {P4 P7} {
        open $positive.$phos.dat w
        ResID top $positive $positive.$phos
    }
}


bigdcd salt $input_dcd

