#input
set n 6
set m 6
set length 3 ;#nm
proc build_CNT { n m length } {
    package require nanotube
    nanotube -l $length -n $n -m $m
    set all [atomselect top all]
    $all writepdb "$n.$m.raw.pdb"
}

proc main {} {
    global n m length
    build_CNT $n $m $length
}

#
main
exit
