#Input Variables to solvate biliar acid in water
# BA are neutral, thus we do not add ions

#pdb of biliar acid without extension
set pdb [lindex $argv 0]

proc main {} {
    global pdb
    center $pdb
    set box [box_size "all" 0]
    set out [open min_max.txt w]
    puts $out "min max (x,y,z) and total is :\n$box"
    close $out
}


proc center {pdb} {
    mol load pdb $pdb.pdb
    set all [atomselect top all]
    $all moveby [vecinvert [measure center $all]]
    $all writepdb $pdb.pdb
    $all delete
}


proc box_size { sel cutoff } {
     set minmax [measure minmax [atomselect top "$sel"]]
     set min_xyz [lindex $minmax 0]
     set max_xyz [lindex $minmax 1]
     
     set min_x [lindex $min_xyz 0]
     set max_x [lindex $max_xyz 0]

     set min_y [lindex $min_xyz 1]
     set max_y [lindex $max_xyz 1]  

     set min_y [lindex $min_xyz 1]
     set max_y [lindex $max_xyz 1]

     set min_z [lindex $min_xyz 2]
     set max_z [lindex $max_xyz 2]
    
     set x_box_size_min [expr $min_x - $cutoff]
     set x_box_size_max [expr $max_x + $cutoff]

     set y_box_size_min [expr $min_y - $cutoff]
     set y_box_size_max [expr $max_y + $cutoff]


     set z_box_size_min [expr $min_z - $cutoff]
     set z_box_size_max [expr $max_z + $cutoff]
      
     
     set box_x [expr abs($min_x)+ abs($max_x) + 2*$cutoff ] 
     set box_y [expr abs($min_y)+ abs($max_y) + 2*$cutoff ]
     set box_z [expr abs($min_z)+ abs($max_z) + 2*$cutoff ]
     
     set box_min_max " $x_box_size_min $y_box_size_min $z_box_size_min $x_box_size_max  $y_box_size_max  $z_box_size_max"
     set box " $box_x $box_y $box_z "
     return "$box"
}

####
main
exit
