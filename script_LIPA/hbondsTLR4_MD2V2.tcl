source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/fit_bigdcd.tcl
source /home/jgarate/script/procedures/distance.tcl
source /home/jgarate/script/procedures/HbondsPostHbondana.tcl

proc hbonds { frame } {
     global cutoff angle SideSel HbondSel outname NumFrames List
     
     fit_bigdcd top "protein"

     for {set i 0} {$i < [llength $List]} {set i [expr $i +2]} {
	  set distance [distance top $SideSel($i,1) $SideSel($i,2)]
	  set out [open $outname($i) a+]
	  set Donor    [measure hbonds $cutoff $angle $HbondSel($i,1) $HbondSel($i,2)]
          set Acceptor [measure hbonds $cutoff $angle $HbondSel($i,2) $HbondSel($i,1) ]
	  set HydrogensIndexDonor [lindex $Donor 2]
          set HydrogensIndexLengthDonor [llength $HydrogensIndexDonor]
          set HydrogensIndexAcceptor [lindex $Acceptor 2]
          set HydrogensIndexLengthAcceptor [llength $HydrogensIndexAcceptor]
          set total [expr $HydrogensIndexLengthAcceptor + $HydrogensIndexLengthDonor]  
	  puts $out [format "%8d        %8f     %8d" $frame $distance $total]
	  close $out

     } 	     
     if {$frame % 100 == 0} { puts "$frame" }
     if {$frame == $NumFrames } {exec perl /home/jgarate/script/procedures/hbondat_fix.pl}

}


if { $argc != 6 } {
        puts "The salt_bridge.tcl script requires 4 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/salt_bridge.tcl path/to/inputpsf path/to/inputdcd path/to/reference_pdb hbonds_data_file frame"
        puts "Please try again."
        exit        
}

set input_psf      [lindex $argv 0]
set input_dcd      [lindex $argv 1]
set reference_pdb  [lindex $argv 2]
set hbondsDataFile [lindex $argv 3]
set NumFrames [lindex $argv 4]
set cutoff   3.5
set angle    30
mol load psf $input_psf
#Get the list of residues involved in hbonds (from ouput file of Hbond  plugin VMD)
#there are some residue that are repeated, thus change this (how?
set List [HbondExtractResidue $hbondsDataFile]
#Do the selections and open output files 
for {set i 0} {$i < [llength $List]} {set i [expr $i + 2] } {
		#puts $i		
		set j [expr $i +1]	
		set pair1          [lindex $List $i]
		set pair2          [lindex $List $j]
		set pair1Resname   [lindex $pair1 0]
		set pair1Resid     [lindex $pair1 1]
		set pair2Resname   [lindex $pair2 0]
		set pair2Resid     [lindex $pair2 1]
		set segid1 [[atomselect top "resname $pair1Resname and resid $pair1Resid and name CA"] get segid]
		set segid2 [[atomselect top "resname $pair2Resname and resid $pair2Resid and name CA"] get segid]
		if { $segid1 eq "MD2"} {
			set outname($i) "$segid1.$pair1Resname.$pair1Resid.$segid2.$pair2Resname.$pair2Resid.RAW"
		} else { set outname($i) "$segid2.$pair2Resname.$pair2Resid.$segid1.$pair1Resname.$pair1Resid.RAW" }

		set out [open $outname($i) w]
		puts  $out "#Frame    SideChain COM Distance  Hbonds   " 
		close $out
		if { [ [atomselect top "resname $pair1Resname and resid $pair1Resid and name CA"] get resname] eq "GLY" } {
			 set SideSel($i,1)  "resname $pair1Resname and resid $pair1Resid and noh"]	
		} else { set SideSel($i,1)  "resname $pair1Resname and resid $pair1Resid and sidechain and noh"}

		if { [ [atomselect top "resname $pair2Resname and resid $pair2Resid and name CA"] get resname] eq "GLY" } {
			set SideSel($i,2)  "resname $pair2Resname and resid $pair2Resid and noh"	
		} else {set SideSel($i,2)  "resname $pair2Resname and resid $pair2Resid and sidechain and noh"}
		
		set HbondSel($i,1) [atomselect top "(resname $pair1Resname and resid $pair1Resid) and (name \"N.*\" \"O.*\" \"S.*\" FA F1 F2 F3)"]
	        set HbondSel($i,2) [atomselect top "(resname $pair2Resname and resid $pair2Resid) and (name \"N.*\" \"O.*\" \"S.*\" FA F1 F2 F3)"]

}
animate read pdb $reference_pdb
bigdcd hbonds $input_dcd
