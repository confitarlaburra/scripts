#TCL-boundary script to apply a time variant ef ii the z direction

wrapmode cell
proc calcforces {step unique } {
     global Eo w dt 
     set t  [expr ($step*$dt)*0.001] 
     set E_t [expr $Eo*cos(expr $w*$t)]

     if { $unique } {
     print "step $step eField intensity = $E_t"
     } 
    
     while {[nextatom]} {
           set charge [getcharge]
           if { $charge == 0 } {
               dropatom
               continue
            }   
            set force_ef [expr $E_t*$charge]
            addforce "0.0 0.0 $force_ef"
           
      
     }

}
