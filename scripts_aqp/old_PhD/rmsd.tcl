proc mass_center { frame } {

	global reference reference_monomer all protein reference_protein 
	foreach NT {A B C D} {
		global monomer_$NT reference_monomer_$NT
		
	}
	$all move [measure fit $protein $reference_protein]
	set rmsd_all [measure rmsd $protein $reference_protein]
	$all move [measure fit $monomer_A  $reference_monomer_A]
	set rmsd_A [measure rmsd $monomer_A  $reference_monomer_A]
	$all move [measure fit $monomer_B  $reference_monomer_B]
	set rmsd_B [measure rmsd $monomer_B  $reference_monomer_B]
	$all move [measure fit $monomer_C  $reference_monomer_C]
	set rmsd_C [measure rmsd $monomer_C  $reference_monomer_C]
	$all move [measure fit $monomer_D  $reference_monomer_D]
	set rmsd_D [measure rmsd $monomer_D  $reference_monomer_D]
	
	set out [open rmsd.out a+]
	puts $out "$frame $rmsd_all $rmsd_A $rmsd_B $rmsd_C $rmsd_D"
	close $out
	if {$frame % 100 == 0} {
		puts "$frame $rmsd_all" 
	}
	
}





set input_psf ../AQP_cw_pope_wi.psf 
set input_dcd ../AQP4_zero.dcd
open rmsd.out w
mol load psf $input_psf
set all [atomselect top all]
set reference_protein [atomselect top "protein and name CA" frame 0]
set protein [ atomselect top "protein and name CA"]
foreach NT { A B C D} {
	set monomer_$NT [atomselect top "chain $NT and name CA"]
	set reference_monomer_$NT [atomselect top "chain $NT and name CA" frame 0]
}
animate read pdb ../AQP_cw_pope_wi.pdb
source bigdcd.tcl
bigdcd mass_center $input_dcd
