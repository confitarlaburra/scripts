if {1} {
proc hbonds { frame } {
     global cutoff angle TLR4Selection MD2Selection MD2SelectionSide TLR4SelectionSide  name1 name2
     
     fit_bigdcd top "protein"
     set distance [distance top $MD2SelectionSide $TLR4SelectionSide] 
     set out [open $name2 a+]
     puts $out "$frame $distance"
     close $out

     set MD2Donor    [measure hbonds $cutoff $angle $MD2Selection $TLR4Selection]
     set MD2Acceptor [measure hbonds $cutoff $angle $TLR4Selection $MD2Selection ]  
 
     set HydrogensIndexDonor [lindex $MD2Donor 2]
     set HydrogensIndexLengthDonor [llength $HydrogensIndexDonor]

     set HydrogensIndexAcceptor [lindex $MD2Acceptor 2]
     set HydrogensIndexLengthAcceptor [llength $HydrogensIndexAcceptor]

     set total [expr $HydrogensIndexLengthAcceptor + $HydrogensIndexLengthDonor]
     set out [open $name1 a+]
     puts $out "$frame $total"
     close $out
 
  if {$frame % 100 == 0} { 
      puts "$frame $total"

  }

}

}

if { $argc != 6 } {
        puts "The salt_bridge.tcl script requires 4 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/salt_bridge.tcl path/to/inputpsf path/to/inputdcd path/to/reference_pdb sel1 sel2"
        puts "Please try again."
        exit        
}

set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]
set reference_pdb [lindex $argv 2]
#segid for MD2 
set sel1          [lindex $argv 3] ; #residue index
#segid for TLR4
set sel2          [lindex $argv 4] ; #residue index
set name1 "MD2.$sel1.TLR4.$sel2.hbonds.dat"
set name2 "MD2.$sel1.TLR4.$sel2.SideChainComDist.dat"
open $name1 w
open $name2 w
mol load psf $input_psf
set MD2Selection  [atomselect top "(segid MD2 and resid $sel1)  and (name \"N.*\" \"O.*\" \"S.*\" FA F1 F2 F3)"]
set TLR4Selection [atomselect top "(segid TLR4 and resid $sel2) and (name \"N.*\" \"O.*\" \"S.*\" FA F1 F2 F3)"]

puts [$MD2Selection get name]
puts [$TLR4Selection get name]

if { [ [atomselect top "segid MD2 and resid $sel1 and name CA"] get resname] eq "GLY" } {
	 set MD2SelectionSide  "resid $sel1  and segid MD2 and noh"
} else { set MD2SelectionSide  "resid $sel1 and sidechain and segid MD2 and noh"
  }

if { [ [atomselect top "segid TLR4 and resid $sel2 and name CA"] get resname] eq "GLY" } {
         set TLR4SelectionSide  "resid $sel2  and segid TLR4 and noh"
} else { set TLR4SelectionSide  "resid $sel2 and sidechain and segid TLR4 and noh"
  }




#set MD2SelectionSide  "resid $sel1 and sidechain and segid MD2 and noh"
#set TLR4SelectionSide "resid $sel2 and sidechain and segid TLR4 and noh"
#h_bonds_parameters 
set cutoff   3.5
set angle    30

animate read pdb $reference_pdb
source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/fit_bigdcd.tcl
source /home/jgarate/script/procedures/distance.tcl
bigdcd hbonds $input_dcd
