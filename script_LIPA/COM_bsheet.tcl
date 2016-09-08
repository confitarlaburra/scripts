#!/usr/bin/tclsh
proc com_b_strands {frame} {
     global  protein strandA strandB strandC strandD strandE strandF strandG strandH strandI 95_113 99_101 99_103
     fit_bigdcd top "protein and name CA"
     set comprot [COM top $protein]
     set A [veclength [vecsub [COM top $strandA] $comprot] ]
     set B [veclength [vecsub [COM top $strandB] $comprot] ]
     set C [veclength [vecsub [COM top $strandC] $comprot] ]
     set D [veclength [vecsub [COM top $strandD] $comprot] ]
     set E [veclength [vecsub [COM top $strandE] $comprot] ]
     set F [veclength [vecsub [COM top $strandF] $comprot] ]
     set G [veclength [vecsub [COM top $strandG] $comprot] ]
     set H [veclength [vecsub [COM top $strandH] $comprot] ]
     set I [veclength [vecsub [COM top $strandI] $comprot] ]
     set out [open ComBstrands.dat a+]
     set collective [expr ($A +$B + $C + $D + $E + $F +$G +$H +$I)/9] 
     puts $out "$frame $A $B $C $D $E $F $G $H $I $collective"
     close $out
     set out [open ComLoop_101.dat a+]
     set dist_95_113 [veclength [vecsub [COM top $95_113 ] $comprot] ]
     set dist_99_101 [veclength [vecsub [COM top $99_101 ] $comprot] ]
     set dist_99_103 [veclength [vecsub [COM top $99_103 ] $comprot] ]
     puts $out "$frame $dist_95_113 $dist_99_101 $dist_99_103"
     close $out
     
     if {$frame%100 == 0} {
        puts "$frame $A $B $C $D $E $F $G $H $I"

    } 
    
}

if { $argc != 4 } {
        puts "The COM_bsheet.tcl script requires 3 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/COM_bsheet.tcl -args path/to/inputpsf path/to/inputdcd path/to/reference_pdb"
        puts "Please try again."
        exit        
}

set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]
set reference_pdb [lindex $argv 2] 

open ComBstrands.dat w
open ComLoop_101.dat w 
animate read pdb $reference_pdb
set protein "protein"
set strandA "protein and resid 21 to 27"
set strandB "protein and resid 30 to 37"
set strandC "protein and resid 45 to 50"
set strandD "protein and resid 57 to 66"
set strandE "protein and resid 75 to 82"
set strandF "protein and resid 85 to 94"
set strandG "protein and resid 113 to 122"
set strandH "protein and resid 129 to 140"
set strandI "protein and resid 144 to 156"

set 95_113 "protein and resid 95 to 113"
set 99_101 "protein and resid 99 100 101"
set 99_103 "protein and resid 99 to 103"

source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/fit_bigdcd.tcl
source /home/jgarate/script/procedures/COM.tcl
bigdcd com_b_strands $input_dcd


