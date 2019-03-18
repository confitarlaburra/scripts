## INPUT ##
### Run example :
# vmd -e AQP4topo_desc.tcl -args A 

#Input PSF
#set psf  /home/jgarate/work/dipole/12AM/common/12A.psf
set psf /home/jgarate/work/dipole/BUILD/BUILD_12AM/input/12A_unsolvated.psf 
#Number of input dcd
set firstDCD 1
set lastDCD  1
#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    #set dcd($i) "12A_out_2.dcd"; # change this
    #set dcd($i) "12A_out.dcd"; # change this
    #set dcd($i) "12A_out_$i.dcd"; # change this
    #set dcd($i) $i.dcd;
    set dcd($i) full.dcd
}

#Path to bigdcd script
set bigdcd /home/jgarate/work/dipole/ANALYSIS/bigdcd.tcl

#Dipole Descrih ptors
#Dipole Magnitude        DIPM
set descriptors {DIPM}
set names(DIPM)  "protein"

set first 0
set min 0
set max 10
set binNum 11




## END INPUT ##

set steps 0

## PROCEDURES ##
#this changes a bit
#Transforms name selections into indexes selections
proc SetIndex { descriptors  &arrName } {
    upvar 1 ${&arrName} names
    foreach  descriptor $descriptors {
	#bad if descriport varies with order
	set temp [ [atomselect top "$names($descriptor)"] get index]
	set indexes($descriptor) $temp
    }
    return [array get indexes]
}


#dipole
#Computes dipole vector and angle against a ref vector
 # of a give selection
proc dipole { dipole  } {
    set sel [atomselect top "index $dipole"]
    set dip [veclength [measure dipole $sel -masscenter]]
    # append normalized dipole vectors
    $sel delete
    return $dip
}


proc WriteFrames {dipoleSel dipole frame } {
    global min max binNum
    set BinSize [expr 1.000*($max-$min)/$binNum] 
    set step [expr int(( ($dipole-$min)/($BinSize) ))]
    if {$step >= 0 &&  $step < $binNum} {
	set DirName [format {%0.2f} [expr $step*$BinSize + $min + $BinSize*0.5]]
	set sel [atomselect top "index $dipoleSel"]
	animate write dcd $DirName/$frame.dcd sel $sel
	$sel delete
    }
}

proc CreateDir { { bool 1} } {
    global min max binNum
    set BinSize [expr 1.000*($max-$min)/$binNum]
    for {set i 0} {$i < $binNum} {incr i} {
	set DirName [format {%0.2f} [expr $i*$BinSize + $min + $BinSize*0.5]]
	if {$bool} { 
	    if { [catch { exec mkdir $DirName } msg] } {
		puts "Something seems to have gone wrong wiht CreteDir but we will ignore it"
	    }
	} else {
	    if { [catch { exec rm -r $DirName } msg] } {
		puts "Something seems to have gone wrong wiht CreteDir but we will ignore it"
	    }
	}
    }
}




# Run analyses of defined descriptors

proc RunAna {descriptors  steps &arrName } {
    upvar 1 ${&arrName} indexes
    foreach  descriptor $descriptors {
	WriteFrames $indexes($descriptor) [dipole $indexes($descriptor)] $steps
    }
}



# Procedure to be run with bigdcd
proc RunTopo {frame} {
    global descriptors names first steps
    incr steps
    if {$steps > $first } {
	array set indexes [SetIndex $descriptors names]
	RunAna  $descriptors $steps indexes
    }
}
## END PROCEDURES ##

## MAIN ##
proc main {&arrName} {
    upvar 1 ${&arrName} dcd 
    global psf bigdcd firstDCD lastDCD descriptors
    global names steps min max binNum
    
    CreateDir 0
    CreateDir
    mol load psf $psf    
    source $bigdcd
    
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    	bigdcd RunTopo $dcd($i)
    	bigdcd_wait
    }
}

#### RUN ##

main dcd
puts "finished with $steps frames!!!"
#exit
