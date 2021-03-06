## INPUT ##
### Run example :
# vmd -e Dipole_sec.tcl
# 


#Input PSF
set psf ../HV1.POPC.Wat.box.ion.ModelA.264.ALA.psf;
set reference_pdb ../HV1.POPC.Wat.box.ion.ModelA.264.ALA.pdb; # pdb with centered channel aligned in z for alignment
#Number of input dcd
set firstDCD 8
set lastDCD  8
#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    #set dcd($i) ../eq$i.dcd
    set dcd($i) ../full_S10.dcd
    #set dcd($i) ../test.dcd
    #set dcd($i) "../eq6.dcd
    #set dcd($i) $i/filtered/full.dcd
    #set dcd($i) $i/out/filtered/full.dcd
}

#Path to bigdcd script
set bigdcd /home/jgarate/HV1/MODELS_Ci-HV1_paperCG/ANA/bigdcd.tcl
#set bigdcd /home/jgarate/work/script/TCL_procedures/bigdcd.tcl
#Dipole Descriptors

set first 0; #First snapshot

set binNumZ  50;  #Numbers of bins along axial Dim
set binNumR  50;   #Numbers of bins along radial Dim
set binNumD  50; #Numbers of bins for Dipole Angles
set binNumDC 50; #Numbers of bins for Disp Corr

set minZ -26; #Min Z value for pore
set maxZ  26; #Max Z value for pore


set minD -1.0; #Min P1 value for dipole
set maxD  1.0; #Max P1 value for dipole

set rad 10; #Radius of pore
set window 10000; #Windows for correlation averaging

set WatNum 11738; # Total Number of waters
#set WatNum 69066; # Total Number of waters
set BoxVol 672280; #in A^3

set MaxLoad 100;# Could be any number >= Minimum Loads of pore

#set descriptors {SELWAT CENTER}
set descriptors {SELWAT FIT}
#set descriptors {FIT}
set names(SELWAT)  "name OH2"; #
#set names(SELWAT)  "not water and resid 255 258 261"; #
set names(FIT)    "protein and name CA"; #Change Depending pore selection
#set names(CENTER)  "protein"; #

## END INPUT ##
#################################################################################################################################### 
### Do not Change!!!


set steps 0
set rad2 [expr $rad*$rad]
set PI  3.14159265359;

# Bin sizes 
# Z: axial bins
# R: Radial bins
# D: P1 bins 
set BinSizeZ  [expr 1.000*($maxZ-$minZ)/$binNumZ]
set BinSizeR  [expr 1.000*($rad)/$binNumR]
set BinSizeD  [expr 1.000*($maxD-$minD)/$binNumD]
set BinSizeDC [expr 1.000*($maxZ-$minZ)/$binNumDC]

# Init Total P1 arrays 
for { set i 0}  {$i < $binNumD} {incr i} {
    set DipColl($i) 0
    set DipSing($i) 0
}

# Init Arrays for Covv Matriox of Dipoles
# within pore positions (ordinal: 1...MaxLoad)
for { set i 0}  {$i < $MaxLoad} {incr i} {
    set ZAxisDipCorr($i) {}
}



# Set arrays of P1 values along z axis
# And loads along z axis
for { set i 0}  {$i < $binNumZ} {incr i} {
    set P1Axis($i) 0
    set LoadsCounter($i) 0
    for { set j 0}  {$j < $binNumR} {incr j} {
	set AxialRad($i,$j) 0
    }
}

# Set Dipole vectors for all water in time
# and bool values wether moles was inside or outside the pore
for { set i 0}  {$i < $WatNum} {incr i} {
    set DipVecs($i) {}
    set HHVecs($i)  {}
    set in_out($i)  {}
    set ZcoordW($i) {}
}

#
set loads_in_time {} ;# Loads in time for loop in correlation
set DipCollCorr {}; # List of Collective dipoles within the pore 
set HHCollCorr {} ; # List of Collective HH vect within the pore 

## PROCEDURES ##


#Transforms name selections into indexes selections
proc SetIndex { descriptors  &arrName } {
    upvar 1 ${&arrName} names
    foreach  descriptor $descriptors {
	#bad if descriport varies with order (e.g. torsion)
	set temp [ [atomselect top "$names($descriptor)"] get index]
	set indexes($descriptor) $temp
	#$temp delete
    }
    return [array get indexes]
}


#Calculate hbonds of (index-based) selection
#Returns total number of H-bonds
# hbonds (selection indexes)
proc calc_hbond {hbonds } {
    set sel [atomselect top "index $hbonds"]
    set cutoff 3.5
    set angle  40
    set hbonds [llength [lindex [measure hbonds $cutoff $angle $sel] 0]]
    $sel delete
    return $hbonds
}

#Structural Fit against a reference structure
#reference_pdb
#selection (selection indexes) 
proc RMSD {selection } {
    set ref [atomselect top "index $selection" frame 0]
    set sel [atomselect top "index $selection"]
    set all [atomselect top all]
    $all move [measure fit $sel $ref]
    set rmsd [measure rmsd $sel $ref]
    $ref delete
    $sel delete
    $all delete
    return $rmsd
} 

#Structural Fit against a reference structure
#reference_pdb
#selection (selection indexes) 
proc center {selection } {
    set sel [atomselect top "index $selection"]
    set all [atomselect top all]
    $all moveby [vecinvert [measure center $sel]]
    set cent [veclength [measure center $sel]] 
    $sel delete
    $all delete
    return $cent
} 




#Order loaded dipoles
#based on axial (z coord)
#position
# Zcoord (list of z coordinates of loaded particle)
# DipLoad (list of dipoles of loaded particle)
# &arrName output Array of ordered dipoles
proc OrderZDip { Zcoord DipLoad &arrName }  {
    upvar 1 ${&arrName} ZAxisDipCorr
    set ZcoordSort [lsort -real $Zcoord]
    for {set i 0} { $i < [llength $ZcoordSort] }  { incr i} {
	set zOrd [lindex $ZcoordSort $i]
	for {set j 0} { $j < [llength $ZcoordSort] }  { incr j} {
	    set z [lindex $Zcoord $j]
	    set Dip [lindex $DipLoad $j]
	    if {$z == $zOrd } {
		lappend ZAxisDipCorr($i) $Dip
	    }
	}
    }
}

#Main Procedure that collects al data of MD 
#trajectory
proc selWaters { allWaters &arrName1 &arrName2 &arrName3 &arrName4 &arrName5 &arrName6 &arrName7 &arrName8 &arrName9 &arrName10  } {
    global minZ maxZ rad rad2; #Binning parameters
    global minD maxD; #Binning parameters
    global BinSizeZ BinSizeR BinSizeD; #Binning parameters
    global binNumZ binNumR binNumD; #Binning parameters
    global loads_in_time; # List of (lists) loaded particles per each frame
    global DipCollCorr HHCollCorr; #List of collective dipoles and HH-vectors
    upvar 1 ${&arrName1}  DipVecs;# Array of lists of all normalized Dip Vectors for all waters
    upvar 1 ${&arrName2}  LoadsCounter;# Total Counter of observations binned in z
    upvar 1 ${&arrName3}  P1Axis;  # Total sum of P1 binned along z axis
    upvar 1 ${&arrName4}  in_out;  # Boolean Array of list indicating  
    upvar 1 ${&arrName5}  AxialRad;# Array of list in 2D for binnig Axial Radial histograms
    upvar 1 ${&arrName6}  HHVecs;  # Array of list of all normalized HH Vectors for all waters
    upvar 1 ${&arrName7}  DipColl; # Array of list of collective Dipoles for binning 
    upvar 1 ${&arrName8}  DipSing; # Array of list of dipoles for binning
    upvar 1 ${&arrName9}  ZcoordW; # Array of list of Zcoord of all particles
    upvar 1 ${&arrName10} ZAxisDipCorr; # Array to coollec ordered Dipoles
    set loadIndexesHbond {}
    set loads {}
    set i 0
    set CollDip {0 0 0}
    set CollHH {0 0 0}
    set Zcoords {}
    set DipLoads {} 
    #loop all water molecules
    foreach index $allWaters {
	# Do selections and collect vectors
	set indexH1 [expr $index +1]
	set indexH2 [expr $index +2]
	set sel [atomselect top "index $index $indexH1 $indexH2"]
	set coord [$sel get {x y z}]
	# Obtain oxygen coordinates
	set x [lindex [lindex $coord 0] 0]
	set y [lindex [lindex $coord 0] 1]
	set z [lindex [lindex $coord 0] 2]
	lappend ZcoordW($i) $z
	set rDist2 [expr $x*$x + $y*$y]
	# Check if  within pore
	if { $rDist2 <= $rad2 && $z >= $minZ && $z <= $maxZ } {
	    # Collect z coord for Dips Correlation
	    #lappend ZcoordW($i) $z
	    set vectorDip [vecnorm [measure dipole $sel -masscenter]]
	    # Collect dipoles vec  for each molecule 
	    #lappend DipVecs($i) $vectorDip
	    set vecH1  [measure center [atomselect top "index $indexH1"]]
	    set vecH2  [measure center [atomselect top "index $indexH2"]]
	    set vecHH  [vecnorm [vecsub $vecH2 $vecH1]]
	    # Collect H-H vec  for each molecule
	    #lappend HHVecs($i) $vecHH
	    lappend loads $i; #list of loads in frame n
	    #Collect Axial coordinate and Dipoles
	    lappend Zcoords $z
	    lappend DipLoads $vectorDip
	    # Load oxygen and hydrogen fo h-bond calc
	    lappend loadIndexesHbond $index
	    lappend loadIndexesHbond $indexH1
	    lappend loadIndexesHbond $indexH2
	    # Accumulate for collective vectors
	    set CollHH  [vecadd $CollHH  $vecHH ]
	    set CollDip [vecadd $CollDip $vectorDip ]
	    # Binning
	    set stepZ [expr int(( ($z-$minZ)/($BinSizeZ) ))]
	    set rDist [expr sqrt($rDist2)]
	    set stepR [expr int(($rDist)/($BinSizeR))]
	    set stepD [expr int(( ([lindex $vectorDip 2]-$minD)/($BinSizeD) ))]
	    # Bin P1 values 
	    if {$stepD < $binNumD} {
		incr DipSing($stepD)
	    }
	    # Accumulate Axial Radial histogram
	    if { $stepZ < $binNumZ && $stepR < $binNumR } {
		incr AxialRad($stepZ,$stepR)
		#Accumulate P1 values, binned along z axis
		set P1Axis($stepZ) [expr $P1Axis($stepZ) +[lindex $vectorDip 2]]
		incr LoadsCounter($stepZ); # and accumulate for averages
	    }
	    lappend in_out($i) 1; # Tag inside 
	} else {
	    #lappend in_out($i) 0; # Tag outside
	    #lappend DipVecs($i) {}
	    #lappend HHVecs($i) {}
	}
	incr i
	$sel delete
    }
    set NormDipColl [vecnorm $CollDip]
    lappend DipCollCorr $NormDipColl
    lappend HHCollCorr  [vecnorm $CollHH]
    set stepD [expr int(( ([lindex $NormDipColl 2]-$minD)/($BinSizeD) ))]
    # Bin Coll P1
    if {$stepD < $binNumD} {
	incr DipColl($stepD)
    }
    lappend loads_in_time $loads; # appends loads(list) in frame n
    #OrderZDip $Zcoords $DipLoads ZAxisDipCorr; # order dipoles based on their position
    # Returns Indexes of Loaded Particles
    # for H-bond calculation
    return $loadIndexesHbond
}




# Unbin P1 Dipoles (single and collective)
proc UnbinDip {&arrName1 &arrName2 } {
    upvar 1 ${&arrName1} DipColl
    upvar 1 ${&arrName2} DipSing
    global binNumD BinSizeD minD
    set out [open "P1_full.dat" w]
    puts $out "#P1 distribution within pore"
    puts $out "#P1         Prob        ProbColl"
    set CountSing 0
    set CountColl 0
    for { set i 0}  {$i < $binNumD} {incr i} {
	set CountSing [expr $CountSing + $DipSing($i)]
	set CountColl [expr $CountColl + $DipColl($i)]
    }
    for { set i 0}  {$i < $binNumD} {incr i} {
	set P1 [format {%8.2f} [expr $i*$BinSizeD + $minD + $BinSizeD*0.5]]
	set NormPS [format {%8.2f} [expr 1.00*$DipSing($i)/$CountSing] ]
	set NormPC [format {%8.2f} [expr 1.00*$DipColl($i)/$CountColl] ]
	puts -nonewline $out $P1
	puts -nonewline $out $NormPS
	puts -nonewline $out $NormPC
	puts $out ""
    }
    close $out
}



#Computes CoVaraince Matrix i.e
# <Dipj*Dipi>
# of an orderded vector of dipoles
proc CovDipZ { &arrName } {
    upvar 1 ${&arrName} ZAxisDipCorr;
    global steps loads_in_time
    
    #Get Total loads in time (single number)
    set Loads {}
    for {set i 0} {$i < $steps} {incr i} {
	lappend Loads [llength [lindex $loads_in_time $i]]
    }
    # Get minimal Load (to have full arrays in time)
    # And define Matrix of "Covariance"
    set MinLoad [lindex [lsort -integer $Loads] 0]
    for { set i 0}  {$i < $MinLoad} {incr i} {
	for { set j 0}  {$j < $MinLoad} {incr j} {
	    set Cov($i,$j) 0.0
	}
    }
    #Compute Matrix (0...MinLoad) of <Dip(j)*Dip(i)> 
    for { set i 0}  {$i < $MinLoad} {incr i} {
	for { set j 0}  {$j < $MinLoad} {incr j} {
	    for {set k 0} { $k < [llength $ZAxisDipCorr($i)] }  { incr k} {
		set Cov($i,$j) [expr $Cov($i,$j) + [vecdot [lindex $ZAxisDipCorr($i) $k] [lindex $ZAxisDipCorr($j) $k] ]]
	    }
	}
    }
    set out [open "CovDipAxis.dat" w]
    puts $out "#Covariance Axial"
    puts $out "#Li          Lj   <Dipj*Dipi>"
    
    for {set i  0} {$i < $MinLoad} {incr i} {
	set Li [format {%8.3f} $i]
	for {set j  0} { $j < $MinLoad} {incr j} {
	    set Lj [format {%8.3f} $j]
	    set Covar [format {%8.3f} [expr $Cov($i,$j)/$steps ]]
	    puts -nonewline $out $Li
	    puts -nonewline $out $Lj
	    puts -nonewline $out $Covar
	    puts $out ""
	}
    }
    close $out
}




#Ubin Average P1 along axial dim
proc UnbinDipZ { &arrName1 &arrName2 } {
    upvar 1 ${&arrName1} P1Axis
    upvar 1 ${&arrName2} LoadsCounter
    global binNumZ BinSizeZ minZ
    set out [open "P1_axial.dat" w]
    puts $out "#AvgP1 along z axis"
    puts $out "#z          <P1>"
    for { set i 0}  {$i < $binNumZ} {incr i} { 
	set z [format {%8.2f} [expr $i*$BinSizeZ + $minZ + $BinSizeZ*0.5]]
	if { $LoadsCounter($i) > 0} {
	    set AverageP1 [format {%8.2f} [expr 1.00*$P1Axis($i)/$LoadsCounter($i)] ]
	} else {
	    set AverageP1 [format {%8.2f} 0 ]
	}
	puts -nonewline $out $z
	puts -nonewline $out $AverageP1
	puts $out ""
    }
    close $out
}


#Ubin Average Load along axial dim
proc UnbinLoadZ {&arrName } {
    upvar 1 ${&arrName} LoadsCounter
    global steps minZ BinSizeZ binNumZ 
    set out [open "Loads_axial.dat" w]
    puts $out "#AvgLoad along z axis"
    puts $out "#z           <Load>"
    for { set i 0}  {$i < $binNumZ} {incr i} { 
	set z [format {%8.2f} [expr $i*$BinSizeZ + $minZ + $BinSizeZ*0.5]]
	set AverageLoad [format {%8.2f} [expr 1.00*$LoadsCounter($i)/$steps] ]
	puts -nonewline $out $z
	puts -nonewline $out $AverageLoad
	puts $out ""
    }
    close $out
}

#Unbin Axial Radial 2D arrays
proc AxRadUnbin {&arrName} {
    upvar 1 ${&arrName} AxialRad
    global steps WatNum Volume
    global minZ maxZ rad PI BoxVol
    global BinSizeZ BinSizeR
    global binNumZ binNumR
    # Set normalization factor for Cylindrical shells 
    set Total_density [expr 1.00*$WatNum/$BoxVol];
    set const_factor  [expr $PI*$BinSizeR*$BinSizeR];
    set norm_factor [expr $Total_density*$const_factor*$steps];
    # Write output
    set out [open "AxialRadDens.dat" w]
    puts $out "#Axial Radial density"
    puts $out "#Z          RAD      P/P0"
    for {set i  0} {$i < $binNumZ} {incr i} {
	set Z [format {%8.2f} [expr $i*$BinSizeZ + $minZ + $BinSizeZ*0.5]]
	for {set j  0} { $j < $binNumR} {incr j} {
	    set RAD [ format {%8.2f} [expr $j*$BinSizeR + $BinSizeR*0.5]];
	    set shell [expr 2*$j + 1 ]
	    set radial_norm_fact [expr $norm_factor*$shell*$BinSizeZ]
	    set 2Density [format {%8.2f} [expr $AxialRad($i,$j)/$radial_norm_fact ]]
	    puts -nonewline $out $Z
	    puts -nonewline $out $RAD
	    puts -nonewline $out $2Density
	    puts $out ""
	}
    }
    close $out
}


#Computes Self correlation of 
#Dipole Vectors and HH vectors
proc SelfCorrWat { &arrName1 &arrName2 &arrName3 } {
    global loads_in_time
    global window steps
    global DipCollCorr HHCollCorr
    upvar 1 ${&arrName1} DipVecs; # Array of lists of all normalized Dip Vectors
    upvar 1 ${&arrName2} HHVecs;  # Array of list all normalized H-H Vectors
    upvar 1 ${&arrName3} in_out;  # Array of list for each particle
    #agregar la self corr de los vectores colectivos

    # Init arrays
    for {set i  0} {$i < $window} {incr i} {
	set P1_list($i) 0;
	set HH_list($i) 0;
	set P1Coll_list($i) 0;
	set HHColl_list($i) 0;
	set average_counter($i) 0;
	set averageColl_counter($i) 0;
    }
    #Windowed and multiple origins loop
    for {set it  0} {$it < [expr $steps-$window]} {incr it} {
	set window_counter 0;
	#loop through frames starting from "it"
	for {set j  $it} { $j < [expr $it+$window]} {incr j} {
	    # Collect for collective vectors
	    set DotDipC [vecdot [lindex $DipCollCorr $j] [lindex $DipCollCorr $it] ]
	    set DotHHC  [vecdot [lindex $HHCollCorr  $j] [lindex $HHCollCorr $it] ]
	    set P1Coll_list($window_counter) [expr $P1Coll_list($window_counter) + $DotDipC ]
	    set HHColl_list($window_counter) [expr $HHColl_list($window_counter) + $DotHHC ]
	    incr averageColl_counter($window_counter)
	    # loop through loaded particles at time it
	    for {set h 0} { $h < [llength [lindex $loads_in_time $it]] }  { incr h} {
		# select particle h loaded at time "it"
		set i [lindex [lindex $loads_in_time $it] $h]
		# if particle i is inside at time "j"
		if { [lindex $in_out($i) $j] } {
		    set DotDip [vecdot [lindex $DipVecs($i) $j] [lindex $DipVecs($i) $it] ]
		    set DotHH  [vecdot [lindex $HHVecs($i)  $j] [lindex $HHVecs($i) $it] ]
		    set P1_list($window_counter) [expr $P1_list($window_counter) + $DotDip ]
		    set HH_list($window_counter) [expr $HH_list($window_counter) + $DotHH ]
		    incr average_counter($window_counter)
		}
	    }
	    incr window_counter;
	}
    }
    #write output
    set out [open "RotDipHH.$window.dat" w]
    puts $out "#<mu(t)dot mu(t0) HH(t)dot HH(t0) and collective versions of loaded water"
    puts $out "#  Window          <mu*mu>       <HH*HH>       <mu*muC>       <HH*HHC>"
    for {set i 0} {$i < $window} {incr i} {
	set win     [format {%11.2f} $i]
	set dotMu   [format {%11.5f} [expr $P1_list($i)/$average_counter($i)] ]
	set dotHH   [format {%11.5f} [expr $HH_list($i)/$average_counter($i)] ]
	set dotMuC  [format {%11.5f} [expr $P1Coll_list($i)/$averageColl_counter($i)] ]
	set dotHHC  [format {%11.5f} [expr $HHColl_list($i)/$averageColl_counter($i)] ]
	puts -nonewline $out  $win
	puts -nonewline $out  $dotMu
	puts -nonewline $out  $dotHH
	puts -nonewline $out  $dotMuC
	puts -nonewline $out  $dotHHC
	puts $out  ""
    }
    close $out
}

proc DispCorr { &arrName1 &arrName2 } {
    upvar 1 ${&arrName1} ZcoordW
    upvar 1 ${&arrName2} in_out;
    global BinSizeDC binNumDC
    global loads_in_time steps
    # init arrays
    for {set i 0} {$i<$binNumDC} {incr i} {
	set corr_dist($i) 0;
	set average_counter($i) 0;
    }
    # Multiple time Origins
    # We start from second frame to compute displacements
    for {set it  1} {$it < $steps} {incr it} {
	for {set j $it} {$j < $steps} {incr j} {
	  # Double loop for displacements of pairs i and m pairs within the the tube
	    for {set h 0} {$h < [llength [lindex $loads_in_time $it] ]} { incr h} {
		set i [lindex [lindex $loads_in_time $it] $h]
		#Check that particle i  is within tube at frame  j
		if { [lindex $in_out($i) $j] } {
		    set disp_i [expr [lindex $ZcoordW($i) $j] - [lindex $ZcoordW($i) [expr $j-1]] ]; # displacement for particle i in t+dt
		    for {set k [expr $h+1]} {$k < [llength [lindex $loads_in_time $it]] } { incr k } {
			set m [lindex [lindex $loads_in_time $it] $k]; #index of atom m loaded in tube at time it
			#Check that particle m  is within tube at frame j
			if { [lindex $in_out($m) $j] } {
			    set disp_m [expr [lindex $ZcoordW($m) $j] - [lindex $ZcoordW($m) [expr $j-1]] ]; # displacement for particle i in t+dt
			    set axial_distance [expr abs( [lindex $ZcoordW($m) $j] - [lindex $ZcoordW($i) $j] ) ];
			    set step [expr int( ($axial_distance)/($BinSizeDC) )]
			    if {$step >= 0 && $step < $binNumDC } { 
				set corr_dist($step) [expr  $corr_dist($step) + $disp_i*$disp_m]; 
				incr average_counter($step);
			    }
			}
		    }
		}
	    }
	}
    }
    #Write output 
    set out [open "DispCorr.dat" w]
    puts $out "#Displacement correlations of loaded water"
    puts $out "#Distance         <DispCorr>"
    for {set i 0} {$i < $binNumDC} {incr i} {
	set distance [format {%11.2f} [expr $i*$BinSizeDC + $BinSizeDC*0.5]]
	if {$average_counter($i) > 0} {
	    set distCorr [format {%11.5f} [expr $corr_dist($i)/$average_counter($i)] ]
	} else {
	    set distCorr [format {%11.5f} 0.00 ]
	}
	puts -nonewline $out  $distance
	puts -nonewline $out  $distCorr
	puts $out  ""
    }
    close $out
}


#Write Initial file: The avoids deletion when loading multiple dcd in a for loop
proc WriteInit {descriptors outname} { 
    set out [open $outname w]
    puts -nonewline $out "# Frame "
    foreach  descriptor $descriptors {
	puts -nonewline $out [ format {%10s} $descriptor]
    }
    puts $out ""
    close $out
}


#Writes results into a single File
proc WriteResult {descriptors outname frame &arrName} {
    upvar 1 ${&arrName} results
    set out [open $outname a+]
    puts -nonewline $out [format {%10s} $frame ]
    foreach  descriptor $descriptors {
	puts -nonewline $out [format {%10.3f} $results($descriptor)]
    }
    puts $out ""
    close $out
} 

# Run analyses of defined descriptors
# arrays names must be declared global if
# a function within a functions uses them
# as arguments
proc RunAna {&arrName } {
    upvar 1 ${&arrName} indexes
    global P1Axis LoadsCounter AxialRad
    global DipVecs HHVecs in_out descriptors
    global DipColl DipSing ZcoordW
    global ZAxisDipCorr
    #set results(CENTER)  [center $indexes(CENTER)]
    set results(FIT)    [RMSD $indexes(FIT)]
    set results(SELWAT) [calc_hbond [selWaters $indexes(SELWAT) DipVecs LoadsCounter P1Axis in_out AxialRad HHVecs DipColl DipSing ZcoordW ZAxisDipCorr ] ]
    return [array get results]
}



# Procedure to be run with bigdcd
proc RunBigDCD {frame} {
    global names first steps descriptors
    if {$steps >= $first } {
	array set indexes [SetIndex $descriptors names]
	array set results [RunAna  indexes]
	WriteResult $descriptors "LoadHbonds.dat" $steps results
    }
    incr steps
}

## END PROCEDURES ##

## MAIN ##
proc main {&arrName } {
    upvar 1 ${&arrName} dcd 
    global psf bigdcd reference_pdb
    global firstDCD lastDCD descriptors 
    global P1Axis LoadsCounter AxialRad
    global DipVecs HHVecs in_out
    global ZAxisDipCorr ZcoordW
    global DipColl DipSing
    WriteInit $descriptors "LoadHbonds.dat"
    mol load psf $psf
    animate read pdb $reference_pdb
    source $bigdcd
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    	bigdcd RunBigDCD $dcd($i)
    	bigdcd_wait
    }
    #Unbin P1 along pore axis
    UnbinDipZ P1Axis LoadsCounter
    #Unbin loads along pore axis
    UnbinLoadZ LoadsCounter
    #Unbin P/P0 Radial Axial
    AxRadUnbin AxialRad
    #Rotational Relaxation fpr Dipoles HH vectors
    #SelfCorrWat DipVecs HHVecs in_out
    #"Covariance" ordered dipoles along axis
    #CovDipZ ZAxisDipCorr
    # Displacement Correlation
    #UnbinDip DipColl DipSing
    #DispCorr ZcoordW in_out
    
}

#### RUN ##

main dcd
exit
