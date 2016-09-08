mol load pdb AQP_cw_pope_wi.pdb
set pore_water  [atomselect top "water or (chain A and resid 77 81 85 93 94 95 97 146 170 174 193 197 201 209 210 211 213 216) or (chain B and resid 77 81 85 93 94 95 97 146 170 174 193 197 201 209 210 211 213 216) or (chain C and resid 77 81 85 93 94 95 97 146 170 174 193 197 201 209 210 211 213 216) or (chain D and resid 77 81 85 93 94 95 97 146 170 174 193 197 201 209 210 211 213 216)"]

$pore_water writepdb pore_water.pdb
set out [open index.out w]
puts $out [$pore_water get index]
close $out
	
