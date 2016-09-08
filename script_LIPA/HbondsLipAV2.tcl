proc hbond { frame } {
     global SugarAcceptor SugarDonor water cutoff angle	Sugar refA
     
     #funciona mejor
     #pbc wrap -center com -all
     #Definitivo
     pbc wrap -center com -centersel "resname LIIV" -all

     #pbc wrap -molid top -sel "water and resname LIIV" -centersel  $refA -all
     #pbc wrap -molid top -sel "and resname LIIV" -centersel $refA -all
     #pbc wrap

     set HbondListDonor [measure hbonds $cutoff $angle $SugarDonor $water]
     set HbondListAcceptor [measure hbonds $cutoff $angle $water $SugarAcceptor ]
     set HbondListIntra [measure hbonds $cutoff $angle $Sugar]
  
 
     set HydrogensIndexDonor [lindex $HbondListDonor 2]
     set HydrogensIndexLengthDonor [llength $HydrogensIndexDonor]

     set HydrogensIndexAcceptor [lindex $HbondListAcceptor 2]
     set HydrogensIndexLengthAcceptor [llength $HydrogensIndexAcceptor]

     set HydrogensIndexInt [lindex $HbondListIntra 2]
     set HydrogensIndexLengthInt [llength $HydrogensIndexInt]

     set total [expr $HydrogensIndexLengthAcceptor + $HydrogensIndexLengthDonor]
     set out [open HbondsWaterSugar.dat a+]
     puts $out "$frame $total $HydrogensIndexLengthAcceptor $HydrogensIndexLengthDonor $HydrogensIndexLengthInt"
     close $out
 
  if {$frame % 100 == 0} { 
      puts "$frame $total $HydrogensIndexLengthInt"

 }

}

if { $argc != 2 } {
        puts "The HbondsLipaV2.tcl script requires 2 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/HbondsLipaV2.tcl -args path/to/inputpsf path/to/inputdcd "
        puts "Please try again."
        exit        
}

set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1] 
#h_bonds_parameters 
set cutoff   3.5
set angle    30

mol load psf $input_psf




open HbondsWaterSugar.dat w


set refA [atomselect top "resname LIIIV"]  
set Sugar         [atomselect top "resname LIIV"]
set SugarAcceptor [atomselect top "resname LIIV and name  OP41 OP43 OP42 O6 O10 OP71 OP72 OP73"]
set SugarDonor    [atomselect top "resname LIIV and name  O6 N2 N8 O10 OP73 OP43"]
set water [atomselect top water]

source /home/jgarate/script/bigdcd.tcl
bigdcd hbond $input_dcd

