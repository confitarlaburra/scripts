proc angle { a b } { 
   # Angle between two vectors 
   set amag [veclength $a] 
   set bmag [veclength $b] 
   set dotprod [vecdot $a $b] 
   return [expr 57.2958 * acos($dotprod / ($amag * $bmag))] 
} 

proc angle_traj {frame} {
     global selection1 selection2
     fit_bigdcd top "protein or resname LIPA"
     set MD2 [measure center [atomselect top "segid MD2"] weight mass]
     set O1 [measure center [atomselect top "resname D193 and name O1"]]
     set F126 [measure center [atomselect top "segid MD2 and resid 126 and name CD2 CG CD1 CE1 CZ  CE2"]]
     set MD2_O1 [vecsub $MD2 $O1]
     set MD2_F126 [vecsub $MD2 $F126]
     set angle [angle $MD2_O1 $MD2_F126]
     set out [open  F126_orientation.dat  a+] 
     puts $out "$frame $angle"
     if {$frame%100 == 0} {puts "$frame $angle"}
     close $out
}

if { $argc != 4 } {
        puts "The angle_F126.tcl script requires 3 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/angle_F126.tcl -args path/to/inputpsf path/to/inputdcd path/to/reference_pdb"
        puts "Please try again."
        exit        
}


set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]
set reference_pdb [lindex $argv 2]

mol load psf $input_psf
animate read pdb $reference_pdb

open F126_orientation.dat w
source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/fit_bigdcd.tcl
bigdcd angle_traj $input_dcd
