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
    set dcd($i) ../eq$i.dcd
    #set dcd($i) ../full_S10.dcd
}

#Path to bigdcd script
set bigdcd /home/jgarate/HV1/MODELS_Ci-HV1_paperCG/ANA/bigdcd.tcl
#Dipole Descriptors

set first 0; #First snapshot

set binNumZ  50;  #Numbers of bins along axial Dim
set binNumD  50; #Numbers of bins for Dipole Angles

set minZ -26; #Min Z value for pore
set maxZ  26; #Max Z value for pore


set minD -1.0; #Min P1 value for dipole
set maxD  1.0; #Max P1 value for dipole

set rad 10; #Radius of pore

#set descriptors {SELWAT CENTER}
set descriptors {SELWAT FIT}
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
set BinSizeD  [expr 1.000*($maxD-$minD)/$binNumD]
# Init Total P1 arrays 
for { set i 0}  {$i < $binNumD} {incr i} {
    set DipColl($i) 0
    set DipSing($i) 0
}
# Set arrays of P1 values along z axis
# And loads along z axis
for { set i 0}  {$i < $binNumZ} {incr i} {
    set P1Axis($i) 0
    set LoadsCounter($i) 0
}
#
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

#Main Procedure that collects al data of MD 
#trajectory
proc selWaters { allWaters &arrName1 &arrName2 &arrName3 &arrName4} {
    global minZ maxZ; #Binning parameters
    global minD maxD; #Binning parameters
    global BinSizeZ BinSizeD; #Binning parameters
    global binNumZ binNumD; #Binning parameters
    upvar 1 ${&arrName1}  LoadsCounter;# Total Counter of observations binned in z
    upvar 1 ${&arrName2}  P1Axis;  # Total sum of P1 binned along z axis
    upvar 1 ${&arrName3}  DipColl; # Array of list of collective Dipoles for binning 
    upvar 1 ${&arrName4}  DipSing; # Array of list of dipoles for binning
    set i 0
    set CollDip {0 0 0}
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
	set rDist2 [expr $x*$x + $y*$y]
	# Check if  within pore
	if { $rDist2 <= $rad2 && $z >= $minZ && $z <= $maxZ } {
	    set vectorDip [vecnorm [measure dipole $sel -masscenter]]
	    #Collect dipoles vec  for each molecule 
	    set CollDip [vecadd $CollDip $vectorDip ]
	    # Binning
	    set stepZ [expr int(( ($z-$minZ)/($BinSizeZ) ))]
	    set stepD [expr int(( ([lindex $vectorDip 2]-$minD)/($BinSizeD) ))]
	    # Bin P1 values 
	    if {$stepD < $binNumD} {
		incr DipSing($stepD)
	    }
	    # Accumulate Axialhistogram
	    if { $stepZ < $binNumZ } {
		set P1Axis($stepZ) [expr $P1Axis($stepZ) +[lindex $vectorDip 2]]
		incr LoadsCounter($stepZ); # and accumulate for averages
	    }
	}
	incr i
	$sel delete
    }
    set NormDipColl [vecnorm $CollDip]
    set stepD [expr int(( ([lindex $NormDipColl 2]-$minD)/($BinSizeD) ))]
    # Bin Coll P1
    if {$stepD < $binNumD} {
	incr DipColl($stepD)
    }
    return $i
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
    global P1Axis LoadsCounter
    global DipColl DipSing
    #set results(CENTER)  [center $indexes(CENTER)]
    set results(FIT)    [RMSD $indexes(FIT)]
    set results(SELWAT) [selWaters $indexes(SELWAT) LoadsCounter P1Axis DipColl DipSing]
    return [array get results]
}

# Procedure to be run with bigdcd
proc RunBigDCD {frame} {
    global names first steps descriptors
    if {$steps >= $first } {
	array set indexes [SetIndex $descriptors names]
	array set results [RunAna  indexes]
	WriteResult $descriptors "RMSDLoads.dat" $steps results
    }
    incr steps
}

## END PROCEDURES ##

## MAIN ##
proc main {&arrName } {
    upvar 1 ${&arrName} dcd 
    global psf bigdcd reference_pdb
    global firstDCD lastDCD descriptors 
    global P1Axis LoadsCounter
    global DipColl DipSing
    WriteInit $descriptors "RMSDLoads.dat"
    mol load psf $psf
    animate read pdb $reference_pdb
    source $bigdcd
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    	bigdcd RunBigDCD $dcd($i)
    	bigdcd_wait
    }
    
    UnbinDipZ P1Axis LoadsCounter
    
    UnbinLoadZ LoadsCounter
    
    UnbinDip DipColl DipSing
    
    
}

#### RUN ##

main dcd
exit
