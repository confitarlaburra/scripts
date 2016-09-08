#!/usr/bin/tclsh

proc ts {frame} {
     global all ligand
     set sasa_ligand_protein  [Sasa "resname LIIV or protein"]
     set sasa_protein [Sasa "protein"]
     set sasa_ligand [Sasa "resname LIIV"]
     set tails_sasa [expr (($sasa_protein + $sasa_ligand) - $sasa_ligand_protein)/2]
     set accesible_area [expr $sasa_ligand - $tails_sasa ]
     set out [open sasa.dat a+]
     #set accesible_area [measure sasa 1.4 $all -restrict $ligand] 
     puts $out [format "%8d %8f" $frame $accesible_area]
     close $out
     if {$frame%100 == 0} { puts "$frame $accesible_area" }
}



if { $argc != 3 } {
        puts "The deltasasa.tcl script requires 2 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/deltasasa.tcl -args path/to/inputpsf path/to/inputdcd"
        puts "Please try again."
        exit        
}


set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]

mol load psf $input_psf
open sasa.dat w
set all [atomselect top "resname LIIV or protein"]
set ligand [atomselect top "resname LIIV"]
source /home/jgarate/script/procedures/sasa.tcl
source /home/jgarate/script/procedures/bigdcd.tcl
bigdcd ts $input_dcd
