proc rgyr {frame} {
      
   #for {set i 1} {$i < 7} {incr i} { 
       global RgyrList  sel5 NumFrames
   #}

   #for {set i 1} {$i < 6} {incr i} {
    #  for {set k [expr $i +1]} {$k < 7} {incr k} {
           global RgyrList sel4 
      #}
   #}
   
   for {set i 1} {$i < 7} {incr i} { 
     lappend RgyrList($i) [measure rgyr $sel5($i)]
   } 
      
      
    for {set i 1} {$i < 6} {incr i} {
      for {set k [expr $i +1]} {$k < 7} {incr k} {
           lappend RgyrList($i,$k) [measure rgyr $sel4($i,$k)]
      }
    }

      if {$frame == $NumFrames} {
          set out2 [open rg_sd.out a+]
          
          for {set i 1} {$i < 7} {incr i} { 
            set out1 [open rgyr_ts$i.dat a+]
            set avg 0
            set j 0
            foreach ryg $RgyrList($i) {
                    puts $out1 "$ryg"
                    set avg [expr $avg + $ryg]
                    incr j 
           }
           set avg [expr $avg/$j]
           set sd 0
           foreach ryg $RgyrList($i) {
                   set sd [expr $sd + ($ryg - $avg)*($ryg - $avg)]
           }
           set sd [expr sqrt ($sd/$j)]
           puts $out2 " $i $avg $sd"
           close $out1
           #close $out2
        }

      
        for {set i 1} {$i < 6} {incr i} {
           for {set k [expr $i +1]} {$k < 7} {incr k} {
                 set out1 [open rgyr_ts$i.$k.dat a+]
                 set avg 0
                 set j 0
                 foreach ryg $RgyrList($i,$k) {
                         puts $out1 "$ryg"
                         set avg [expr $avg + $ryg]
                         incr j 
                 }
                set avg [expr $avg/$j]
                set sd 0
                foreach ryg $RgyrList($i,$k) {
                        set sd [expr $sd + ($ryg - $avg)*($ryg - $avg)]
                }
                set sd [expr sqrt ($sd/$j)]
                puts $out2 " $i.$k $avg $sd"
                close $out1
            }
        }
        close $out2
     } 
      
         
      
      if {$frame % 100 == 0} {
          puts $frame 
      } 

}


set input_psf ../lipidIVA_solvate_ion.psf
set input_dcd ../total.dcd
set NumFrames 10000
#set SkipFrames 0

mol load psf $input_psf 

open rg_sd.out w


set tail(1) "C13 O13 C14 C15 C16 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26"
set tail(2) "O15 C27 O27 C28 C29 C30 C31 C32 C33 C34 C35 C36 C37 C38 C39 C40"
set tail(3) "C41 O41 C42 C43 C44 C45 C46 C47 C48 C49 C50 C51 C52 C53 C54"
set tail(4) "O43 C55 O55 C56 C57 C58 C59 C60 C61 C62 C63 C64 C65 C66"
set tail(5) "C67 O67 C68 C69 O69 C70 C71 C72 C73 C74 C75 C76 C77 C78 C79 C80"
set tail(6) "C81 O81 C82 C83 O83 C84 C85 C86 C87 C88 C89 C90 C91 C92 C93 C94"

#Combination for removing one tail 
for {set i 1} {$i < 7} {incr i} {
     set Sel5Text($i) "resname LIIV and name "
     open rgyr_ts$i.dat w
     set RgyrList($i) {}
     for {set j 1} {$j < 7} {incr j} {
           if {$i != $j } {
              set Sel5Text($i) "$Sel5Text($i) $tail($j)"
           }
           if {$j == 6} { 
              set  sel5($i) [atomselect top "$Sel5Text($i)"] 
           } 
     } 
}

#Combination for removing two tails
for {set i 1} {$i < 6} {incr i} {
      for {set k [expr $i +1]} {$k < 7} {incr k} {
           set Sel4Text($i,$k) "resname LIIV and name "
           open rgyr_ts$i.$k.dat w
           set RgyrList($i,$k) {}
           for {set j 1} {$j < 7} {incr j} {
                 if {$i != $j  && $k != $j } {
                     set Sel4Text($i,$k) "$Sel4Text($i,$k) $tail($j)"
                 } 

                 if {$j == 6} {
                     set sel4($i,$k) [atomselect top "$Sel4Text($i,$k)"]
                 }
           }   
      }
}


source /home/jgarate/script/bigdcd.tcl
bigdcd rgyr $input_dcd
