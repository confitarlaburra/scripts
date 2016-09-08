#!/usr/bin/tclsh
proc Sasa {frame} {
     set deltasasa [DeltaSasa "protein" "segid MD2" "segid TLR4" "top"]
     set out [open deltasasa.dat a+]
     puts $out [format "%8d %8f" $frame $deltasasa]
     close $out
     if {$frame%1 == 0} { puts "$frame $deltasasa" }
}



if { $argc != 3 } {
        puts "The deltasasa.tcl script requires 2 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/deltasasa.tcl -args path/to/inputpsf path/to/inputdcd"
        puts "Please try again."
        exit        
}


set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]
set reference_pdb [lindex $argv 2] 

mol load psf $input_psf
open deltasasa.dat w
source /home/jgarate/script/procedures/DeltaSasa.tcl
source /home/jgarate/script/procedures/bigdcd.tcl
bigdcd Sasa $input_dcd
