proc hbond { frame } {
     global SugarAcceptor SugarDonor water cutoff angle	Sugar
     
       

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



set input_psf MD2_lipIVA_flipped_solv_box_ion.psf
set input_dcd eq6.dcd

mol load psf $input_psf

#h_bonds_parameters 
set cutoff   3.5
set angle    30

open HbondsWaterSugar.dat w



set Sugar         [atomselect top "resname LIIV"]
set SugarAcceptor [atomselect top "resname LIIV and name  OP41 OP43 OP42 O6 O10 OP71 OP72 OP73"]
set SugarDonor    [atomselect top "resname LIIV and name  O6 N2 N8 O10 OP73 OP43"]
set water [atomselect top water]
source bigdcd.tcl
bigdcd hbond $input_dcd

