#!/usr/bin/tclsh
proc rmsd_traj {frame} {
     set rmsd [rmsd_bigdcd  top "segid MD2 and name CA"]
     set out [open rmsd_traj.dat a+]
     puts $out "$frame $rmsd"
     close $out
     if {$frame%100 == 0} { puts "$frame $rmsd" }
}


if { $argc != 4 } {
        puts "The rmsd_traj.tcl script requires 3 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/rmsd_traj.tcl -args path/to/inputpsf path/to/inputdcd path/to/reference_pdb"
        puts "Please try again."
        exit        
}

set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]
set reference_pdb [lindex $argv 2] 

mol load psf $input_psf
animate read pdb $reference_pdb
open rmsd_traj.dat w
source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/rmsd_bigdcd.tcl
bigdcd rmsd_traj $input_dcd
