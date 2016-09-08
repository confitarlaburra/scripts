proc rmsf_CA { {mol top} {outfile rmsf.dat} {first_res 1} selection } {
          set sel [atomselect top "$selection"]
          set out [open $outfile w]
          set rmsf_list [measure rmsf $sel]
          set i $first_res
          foreach rmsf $rmsf_list {
                  puts $out "$i $rmsf"
                  incr i
          }         
          close $out 
}
