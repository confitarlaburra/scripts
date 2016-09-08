#!/usr/bin/tclsh
proc Coord {frame} {
     global cutoff selection1 selection2
     set Coordination [AvgCoordNumb top $selection1 $selection2 $cutoff ]
     if {$frame%100 == 0} { puts "$frame $Coordination" }
     set out [open Coordination.dat a+]
     set frame [format "%8d" $frame]
     puts $out "$frame $Coordination"
     close $out
     
}



if { $argc != 4 } {
        puts "The coordination.tcl script requires 3 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/coordination.tcl -args path/to/inputpdb path/to/inputdcd cutoff"
        puts "Please try again."
        exit        
}


set input_pdb     [lindex $argv 0]
set input_dcd     [lindex $argv 1] 
set cutoff        [lindex $argv 2] 
set selection1 "name PA PB PG"
set selection2 "name NA"
mol load pdb $input_pdb
open Coordination.dat w
source /home/jgarate/script/procedures/AvgCoordNumber.tcl
source /home/jgarate/script/procedures/bigdcd.tcl
bigdcd Coord $input_dcd
