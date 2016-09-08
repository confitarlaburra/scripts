#!/usr/bin/tclsh
proc rgyr {frame} {
      global   RgyrList NumFrames
	set sel [atomselect top "resname LIIV and noh and not name O12 C1 C2 C3 C4 O4 P4 OP41 OP42 OP43 C5 O5  C6 O6 O1 C12 C11 O11 C7 O7 P7 OP71 OP72 OP73 O3 C8 C13 O13 N2 C41 O41  C9 O9 C10 O10 C67 O67 N8 C81 O81"]

      	lappend RgyrList [measure rgyr $sel ]
      
      if {$frame == $NumFrames} {
          set out1 [open rg_ts.dat a+]
          set out2 [open rg_sd.out a+]
          set avg 0.0
          set i 0
          foreach ryg $RgyrList {
                 puts $out1 "$i $ryg"
                 set avg [expr $avg + $ryg]
                 incr i 
         }
         set avg [expr $avg/$i]
         set sd 0.0
         foreach ryg $RgyrList {
                 set sd [expr $sd + ($ryg - $avg)*($ryg - $avg)]
         }
         set sd [expr sqrt ($sd/$i)]
         puts $out2 "$avg $sd"
         close $out1
         close $out2
      }
      
      if {$frame % 100 == 0} {
          puts $frame 

      } 

}



if { $argc != 5 } {
        puts "The rgyr.tcl script requires 4 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/rgyr.tcl -args path/to/inputpsf path/to/inputdcd  numframes skipframes "
        puts "Please try again."
        exit        
}


set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]    
set NumFrames     [lindex $argv 2]
set SkipFrames    [lindex $argv 3]

mol load psf $input_psf 

open rg_ts.dat w
open rg_sd.out w

set RgyrList {}
set sel [atomselect top "resname LIIV and noh and not name O12 C1 C2 C3 C4 O4 P4 OP41 OP42 OP43 C5 O5  C6 O6 O1 C12 C11 O11 C7 O7 P7 OP71 OP72 OP73 O3 C8 C13 O13 N2 C41 O41  C9 O9 C10 O10 C67 O67 N8 C81 O81"]
$sel get resid;
source /home/jgarate/script/bigdcd.tcl
bigdcd rgyr $input_dcd
