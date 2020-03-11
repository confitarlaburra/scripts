## INPUT ##

#Input PSF
set psf   ../../TRPV1.POPE.Wat.box.ion.psf 
set reference_pdb  ../../TRPV1.POPE.Wat.box.ion.pdb
#Number of input dcd
set firstDCD 8
set lastDCD  9
set steps 0
#inputs dcd (asumes that dcd start with "eq")
for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    set dcd($i) "../eq$i.dcd"
}

#set descriptors {RMSD RGYR SASA}
set descriptors {RMSD RGYR}
#Atoms Names comprising each descriptor

set selTextRMSD  "protein and name CA"
set selTextRGYR  "protein"
#set selTextSASA  "resname LIG"

set selections(RMSD)  $selTextRMSD
set selections(RGYR)  $selTextRGYR
#set selections(SASA)  $selTextSASA


#Path to bigdcd script
set bigdcd /home/jgarate/opt/scripts/script_dipole/bigdcd.tcl
#outname
set outname RMSD_RGYR_SASA.dat
#First frame to perform analyes
set first 1

## END INPUT ##



## PROCEDURES ##

proc SASA { selection  } {
    set sel [atomselect top "$selection"]
    set Sasa [measure sasa 1.4 $sel]
    return $Sasa
}


proc RMSD {selection } {
    set ref [atomselect top "$selection" frame 0]
    set sel [atomselect top "$selection"]
    set all [atomselect top all]
    $all move [measure fit $sel $ref]
    set rmsd [measure rmsd $sel $ref]
    return $rmsd
} 

proc RGYR {selection} {
    set sel [atomselect top "$selection"]
    set rgyr [measure rgyr $sel]
    return $rgyr
}

# Run analyses of defined descriptors

proc RunAna {descriptors  &arrName } {
    upvar 1 ${&arrName} selections
    foreach  descriptor $descriptors {
	set results($descriptor) [$descriptor $selections($descriptor)]
    }
    return [array get results]
}

#Writes results into a single File
proc WriteResult {descriptors outname frame &arrName} {
    upvar 1 ${&arrName} results
    set out [open $outname a+]
    puts -nonewline $out [format {%10s} $frame ]
    foreach  descriptor $descriptors {
	puts -nonewline $out [format {%10.2f} $results($descriptor)]
    }
    puts $out ""
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


# Procedure to be run with bigdcd
proc RunTopo {frame} {
    global descriptors selections first outname steps 
    array set results [RunAna  $descriptors selections]
    incr steps
    WriteResult $descriptors $outname $steps results
}

## END PROCEDURES ##

## MAIN ##
proc main {&arrName} {
    upvar 1 ${&arrName} dcd 
    global psf reference_pdb numDCD bigdcd firstDCD lastDCD outname descriptors
    WriteInit $descriptors $outname 
    mol load psf $psf
    animate read pdb $reference_pdb
    source $bigdcd
    for {set i $firstDCD} {$i <= $lastDCD} {incr i} {
    	bigdcd RunTopo $dcd($i)
    	bigdcd_wait
    }
}

#### RUN ##

main dcd
puts "finished with $steps frames!!!"
exit
