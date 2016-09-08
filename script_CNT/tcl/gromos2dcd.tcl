set fit_selection "resname CCC"
set dcd_selection "all"
proc fit { {mol top} selection  } {
     
     set ref [atomselect $mol "$selection" frame 0]
     set sel [atomselect top "$selection"]
     set all [atomselect top all]
     set nf [molinfo $mol get numframes]
     for {set frame 0} {$frame < $nf} {incr frame} {
         $sel frame $frame
         $all frame $frame 
     	 $all move [measure fit $sel $ref]
     }

} 
set pdbname FRAME_00005.pdb
mol load pdb $pdbname
fit top $fit_selection
set frame1 [atomselect top all frame 0]
$frame1 writepdb 01.pdb
set all [atomselect top $dcd_selection]
animate write dcd trajectory.dcd $all
mol delete all
mol load pdb 01.pdb
mol addfile trajectory.dcd waitfor all
