#script that computes the collective model of zhu and schulten for a single pore  of the AQP4 system

proc permeation { frame } {
  global chain range  i n n100 timeWind skipFrame numframes numframes numElements n2 pore wat zList 
  
#open ouput file in append mode
  set out [open $chain.Nt.dat a+]
#list of z coordinates off all water oxygens from the actual frame an previous one 
  set zListOld $zList
  set zList [$wat get z]
#boundaries of the constriction region of a single pore
  set poreMinMax [measure minmax $pore]
  set min_xyz [lindex $poreMinMax 0]
  set max_xyz [lindex $poreMinMax 1]
  
  set min_z [lindex $min_xyz 2]
  set max_z [lindex $max_xyz 2]

  set PoreLength [expr abs($max_z - $min_z)] 
  
  set center_pore [measure center $pore]
  set pore_x [lindex $center_pore 0]
  set pore_y [lindex $center_pore 1]	
  set min_x  [expr $pore_x - $range]
  set min_y  [expr $pore_y - $range]
  set max_x  [expr $pore_x + $range]
  set max_y  [expr $pore_y + $range]
   
#counter set to zero,  
  set dzAll 0
  set pLoading 0

#iterates over each water molecule, locates the ones that are and were inside the pore
# and computes their unidimensional (z) displacement, dz
# dz is accumulated in dzAll
# also counts the amount of waters molecules inside the pore
  if {$frame > $skipFrame && $frame <= $numframes } {
        set realFrame [expr $frame - $skipFrame]
  	foreach z $zList z_old $zListOld x [$wat get x] y [$wat get y] {
		if {$z > $min_z && $z < $max_z && $z_old > $min_z && $z_old < $max_z && $x > $min_x && $x < $max_x && $y > $min_y && $y < $max_y} {
      			set dz [expr $z - $z_old]
			set dzAll [expr $dzAll + $dz]
			incr pLoading
		}
  	}
#computes collective variable dn and intregrates it (summing up) getting n(t)              
  	set dn [expr $dzAll/$PoreLength]
      	set n [expr $n + $dn]
	set n100 [expr $n100 + $dn]
        puts $out "$realFrame $n $pLoading"
  	set N2 [expr $n100*$n100]
#computes the msd of n, N2 and accumualtes for every timewind frame  	
	set n2($i) [expr $n2($i) + $N2]
  	incr i
  	if {$frame % $timeWind == 0} {
      		set i 0
		set n100 0
		puts "$frame $n $N2 $pLoading $PoreLength"
  	}  	 	
  }
#computes the averages for the N2 value
  if {$frame == $numframes} {
	set out2 [open $chain.N2.dat a+]
	puts $out2 "0 0.0"
	for {set j 0} {$j < $timeWind} {incr j} {
		set t [expr $j +1]		
		set avgN2 [expr $n2($j)*$numElements]
		puts $out2 "$t $avgN2"
	}
     	close $out2   			
  }

  close $out

}

#input psf and dcd
set input_psf ../AQP_cw_pope_wi.psf 
set input_dcd ../AQP4_zero.dcd
#set the chain (pore)
set chain "D"
#set some variables of the pore
set range 3.5
#set counters, and other variables
set n 0
set n100 0
set i 0
set timeWind 100
set skipFrame 5000
set numframes 100000
set totalFrames [expr $numframes - $skipFrame]
set numElements [expr $totalFrames/$timeWind]
set numElements [expr 1.0/$numElements]
#set the array for the N2 averaging
for {set id 0} {$id  < $timeWind} {incr id} {
    set n2($id) 0
}

#load psf and define some selections for the selected pore and all water molecules
mol load psf $input_psf
if {$chain eq "A"} {
	set pore [atomselect top "index 40643 40256 39054 40861"]
} elseif {$chain eq "B"} {
	set pore [atomselect top "index 44179 44397 43792 42590"]
} elseif {$chain eq "C"} {
	set pore [atomselect top "index 47715 47933 47328 46126"]	
} else {
	set pore [atomselect top "index 51251 51469 50864 49662"]	
}

set wat [atomselect top "name OH2"]
set segList [$wat get segname]
# init some variables and list
set zList {} 
foreach foo $segList {
	lappend zList 0
}
#open output files
set out [open $chain.Nt.dat w]
puts $out "0 0.0"
close $out
open $chain.N2.dat w
#run the script
source bigdcd.tcl
bigdcd permeation $input_dcd


