proc orientation {frame} {
  global all slWidth slWidth_d WaterOut OctaneOut LipAout numframes SkipFrames n_oct n_wat n_lipA icntO OctaneMass WaterMass
  
  set min_max [measure minmax $all]
  
  set min [lindex $min_max 0]
  set max [lindex $min_max 1]
  
  set min_x [lindex $min 0]
  #puts $min_x
  set max_x [lindex $max 0]
  
  set min_y [lindex $min 1]
  set max_y [lindex $max 1]
  
  set min_z [lindex $min 2]
  set max_z [lindex $max 2]
  
  set BoxLength_x [expr abs($min_x) + abs($max_x)]
  set nslices [expr $BoxLength_x*$slWidth_d]
  set nslices [expr int($nslices)] 
  #puts "$nslices"

  set BoxLength_y [expr abs($min_y) + abs($max_y)]
  set BoxLength_z [expr abs($min_z) + abs($max_z)]
  set SliceVolume [expr $BoxLength_y*$BoxLength_z*$slWidth]
  set SliceVolume [expr 1/$SliceVolume]  
  #puts "$BoxLength_y $BoxLength_z $SliceVolume"
  if {$frame >= $SkipFrames} {
    for {set i 0} {$i < $nslices} {incr i} {
        
       set j [expr $i*$slWidth]
       #puts $j
       set x_min [expr $min_x + $j ]
       set x_max [expr $x_min + $slWidth]
       #puts "$x_min $x_max"     
       set waters [atomselect top "name OH2 and x >= $x_min and x <= $x_max"]
       set WatResid [$waters get resid]
       set WaterNumber  [llength $WatResid]	
       set WaterDensity [expr $WaterNumber*$SliceVolume*$WaterMass]
       set n_wat($i) [ expr $n_wat($i) + $WaterDensity]
       #puts "$WaterNumber $WaterDensity"
       #puts $n_wat($i)
       
       set octanes [atomselect top "resname OCT and x >= $x_min and x <= $x_max and carbon"]
       set OctResid [$octanes get resid]
       set OctaneNumber [llength $OctResid]
       set OctaneDensity [expr $OctaneNumber*$SliceVolume*12.01070]	
       set n_oct($i) [ expr $n_oct($i) + $OctaneDensity]       
       #puts "$OctaneNumber $OctaneDensity"
       #puts $n_oct($i)
       
       set lipAC [atomselect top "resname LIIV and x >= $x_min and x <= $x_max and carbon"]
       set LipACResid [$lipAC get index]
       set lipACMass [expr 12.01070*[llength $LipACResid]]

       set lipAO [atomselect top "resname LIIV and x >= $x_min and x <= $x_max and oxygen"]
       set LipAOResid [$lipAO get index]
       set lipAOMass [expr 15.99940*[llength $LipAOResid]]
       
       set lipAN [atomselect top "resname LIIV and x >= $x_min and x <= $x_max and nitrogen"]
       set LipANResid [$lipAN get index]
       set lipANMass [expr 14.00670*[llength $LipANResid]]
       
       set lipAP [atomselect top "resname LIIV and x >= $x_min and x <= $x_max and (name P4 or name P7)"]
       set LipAPResid [$lipAP get index]
       set lipAPMass [expr 30.97376*[llength $LipAPResid]]
       
       set TotalMassLipA [expr $lipACMass + $lipAOMass + $lipANMass + $lipAPMass]

       set LipADensity [expr $TotalMassLipA*$SliceVolume]	
       set n_lipA($i) [ expr $n_lipA($i) + $LipADensity] 

       
       set icntO($i)   [ expr $icntO($i)   + 1 ]       
 
       $waters  delete 
       $octanes delete 
       $lipAC delete
       $lipAO delete
       $lipAN delete
       $lipAP delete
       
   }      
 }

  if { $frame == $numframes } {
		set out1 [open $WaterOut a+]
                set out2 [open $OctaneOut a+]
                set out3 [open $LipAout a+]
                puts "holas"
		for {set i 0} {$i  < $nslices} {incr i} {
       			set xtemp [ expr double($i)       ]
       			set xtemp [ expr $xtemp*$slWidth   ]

			if { $icntO($i) != 0 } {
           			set n_wat($i) [ expr $n_wat($i) / $icntO($i) ]
           			set n_oct($i) [ expr $n_oct($i) / $icntO($i) ]
                                set n_lipA($i) [ expr $n_lipA($i) / $icntO($i) ] 
			} 
			puts $out1 "$xtemp $n_wat($i)"
	 		puts $out2 "$xtemp $n_oct($i)"
                        puts $out3 "$xtemp $n_lipA($i)"	
                 }
	              
     close $out1
     close $out2
     close $out3
  }


if {$frame % 100 == 0} {
		puts $frame 
	}

}
set input_psf lipidIVA_interface_OCT_water_ion.psf
set input_dcd total.dcd
set numframes 10000
set SkipFrames 1000
set nslices 100
#set OctaneMass 114.23 
set WaterMass 15.99940

mol load psf $input_psf 

set WaterOut "density_water.out"
open $WaterOut w

set OctaneOut "density_octane.out"
open $OctaneOut w

set LipAout "density_lipA.out"
open $LipAout w

set all [atomselect top all]

#set nslices  100
for {set i 0} {$i  < $nslices} {incr i} {
    set n_oct($i)    0
    set n_wat($i)    0
    set n_lipA($i)   0
    set icntO($i)    0

}
set slWidth  2.0
set slWidth_d [expr 1/2.0]

source /home/jgarate/script/bigdcd.tcl
bigdcd orientation $input_dcd
