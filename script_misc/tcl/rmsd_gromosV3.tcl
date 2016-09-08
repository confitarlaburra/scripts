#!/usr/bin/tclsh
if { $argc != 4 } {
        puts "The rmsd_gromos.tcl script requires 3 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/rmsd_gromos.tcl -args path/to/inputpsf path/to/inputdcd  frames_begin"
        puts "Please try again."
        exit        
}

set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]    
set frames_begin  [lindex $argv 2]

mol load psf $input_psf
mol addfile $input_dcd waitfor all

set numFrame [molinfo top get numframes]
set all [atomselect top all]
set sel1 [atomselect top "resname LIIV and name C2 C1 C3 C4 C5 O5 O1 C12 C11 C10 C9 C8 C7 O11"]
set sel2 [atomselect top "resname LIIV and name C2 C1 C3 C4 C5 O5 O1 C12 C11 C10 C9 C8 C7 O11"]
set fit1sel  [atomselect top "resname LIIV and name C2 C1 C3 C4 C5 O5 O1 C12 C11 C10 C9 C8 C7 O11"]
set fit2sel  [atomselect top "resname LIIV and name C2 C1 C3 C4 C5 O5 O1 C12 C11 C10 C9 C8 C7 O11"]
#set sel1 [atomselect top "name C2 C1 C3 C4 C5 O5 O1 C12 C11 C10 C9 C8 C7 O11"]
#set sel2 [atomselect top "name C2 C1 C3 C4 C5 O5 O1 C12 C11 C10 C9 C8 C7 O11"]
#set fit1sel  [atomselect top "name C2 C1 C3 C4 C5 O5 O1 C12 C11 C10 C9 C8 C7 O11"]
#set fit2sel  [atomselect top "name C2 C1 C3 C4 C5 O5 O1 C12 C11 C10 C9 C8 C7 O11"]
set natoms [$sel1 num]
set NumframesTitle [expr $numFrame -1]

set outfile1 [open rmsd_matx.dat  w]
set outfile2 [open rmsd_hist.dat w]
puts $outfile1  "TITLE"
puts $outfile1 "        rmsd-matrix for $NumframesTitle =  $numFrame structures "
puts $outfile1 "END"
puts $outfile1 "RMSDMAT"
puts $outfile1 "# number of frames  skip  stride"
puts $outfile1 "$numFrame      0       1"
puts $outfile1 "#precision"
puts $outfile1 "10000"

 

#fitting 
 $fit1sel frame $frames_begin
 for { set f $frames_begin } { $f < $numFrame } { incr f } {
	   $fit2sel frame $f
	   $all frame $f
	   $all move [measure fit $fit2sel $fit1sel]
        }


#rmsd calculation
for { set f1 $frames_begin } { $f1 < [expr $numFrame -1] } { incr f1 } {
	$sel1 frame $f1
	for { set f2 [expr $f1 +1] } { $f2 < $numFrame } { incr f2 } {
	    $sel2 frame $f2
            set rmsd [measure rmsd $sel1 $sel2]
            puts $outfile2 "$rmsd"
            set rmsd [expr int($rmsd*1000)]
            set ref [string range [format " %7i" $f1] end-7 end]
            set str [string range [format "%7i" $f2] end-7 end]
            set rms_f [string range [format "%7i" $rmsd] end-7 end]
            puts $outfile1 "$ref $str $rms_f"
        }
if {$f1 % 100 == 0} {
   puts "$f1"	 
  }
}
    

puts $outfile1 "END"
close $outfile1
close $outfile2




