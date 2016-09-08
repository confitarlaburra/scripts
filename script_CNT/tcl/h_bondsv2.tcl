proc permeation { frame } {
	global oxygen_nt wat_nt cutoff angle nano numframes hbonds icntO name_out_1 name_out_2 PoreLoad
	
        
		
	if {$frame%1000 == 0} {puts "measuring h_bonds frame $frame ...."}
	
	set nano_min_max [measure minmax $nano]
  	set min_xyz [lindex $nano_min_max 0]
  	set max_xyz [lindex $nano_min_max 1]
  
  	set min_x [lindex $min_xyz 0]
  	set min_y [lindex $min_xyz 1]
  	set min_z [lindex $min_xyz 2]

  	set max_x [lindex $max_xyz 0]
  	set max_y [lindex $max_xyz 1]
  	set max_z [lindex $max_xyz 2]
        # Get hbonds and number of water in CNT
	set oxygen_nt [atomselect top "name OW and z > $min_z and z < $max_z and x > $min_x and x < $max_x and y > $min_y and y < $max_y"]
	set water  [atomselect top    "resname SOLV and z > $min_z and z < $max_z and x > $min_x and x < $max_x and y > $min_y and y < $max_y"]   	
	set water_nt [$oxygen_nt get index]
    	set water_nt_number [llength $water_nt]
	set hbonds_list [measure hbonds $cutoff $angle $water]
	set hydrogens_index [lindex $hbonds_list 2]
	set hydrogens_index_length [llength $hydrogens_index]
	
	# define a bin
        set bin   [ expr int($water_nt_number) ]
	## fill correspondig array
	set hbonds($bin)   [ expr $hbonds($bin) + $hydrogens_index_length ]
	set hbonds($bin)   [ expr double($hbonds($bin))         ]
	#
	# bin into histograms
	#
	set icntO($bin)   [ expr $icntO($bin)   + 1 ]
	#normalize
	if {$frame == $numframes} {
		set out1 [open $name_out_2 a+]
		for {set id 0} {$id  <= $PoreLoad} {incr id} {
       			set wtload [ expr double($id)         ]
			if { $icntO($id) != 0  &&  $wtload != 0 } {
           			set hbonds($id) [ expr ($hbonds($id) / ( $wtload*$icntO($id) ) ) ]
			}
			set formatstring {%10.3f%10.3f}
			puts $out1 [format $formatstring "$wtload" "$hbonds($id)"]	
    		}     
    		close $out1
		puts "Done!!!"
        }
   
	set formatStr {%7d%7d%7d}
        set out [open $name_out_1 a+]
    	puts $out [format $formatStr "$frame" "$hydrogens_index_length" "$water_nt_number"]
    	close $out
}



set input_pdb ../01.pdb
set input_dcd ../trajectory.dcd
set numframes "10000"
mol load pdb $input_pdb

#h_bonds_parameters 
set nano [atomselect top "resname CCC"]
set cutoff   4.0
set angle    30


#Number of bins (water max load number)
set PoreLoad  7

#
# zero arrays to contain order params, histograms, and counters
#

for {set id 0} {$id  <= $PoreLoad} {incr id} {
    set hbonds($id)    0
    set icntO($id) 0

}

#out 1 (time series)
set name_out_1 "h_bonds_water_nt.dat"
set out [open $name_out_1 w]
set formatStr {%7s%7s%7s}
puts $out [format $formatStr "#Frame" "N_hydrogens" "N_waters"]
close $out
#out 2 (loads vs hbonds averages)
set name_out_2 "water_load_vs_hbods.dat"
set out [open $name_out_2 w]
set formatStr {%10s%10s}
puts $out [format $formatStr "#N_waters" "N_hbonds"]
close $out

source /home/jgarate/script/bigdcd.tcl
bigdcd permeation $input_dcd






 
