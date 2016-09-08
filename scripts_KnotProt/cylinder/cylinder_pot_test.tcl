set V0    1
set rho0  1
set z0    0.5

set rho02 [expr $rho0*$rho0]
set z09   [expr $z0**9]

proc EFpore {V0 rho02 x y } {
    set rho2     [expr $x*$x + $y*$y]
    set ExpFact  [expr exp(1-($rho2)/($rho02))]
    set PlusFact [expr 1 + $ExpFact]
    set Epore    [expr $V0/$PlusFact] 
    set phi      [expr (2*$V0*$ExpFact)/($PlusFact*$PlusFact*$rho02)]
    set Fx       [expr -$phi*$x]
    set Fy       [expr -$phi*$y] 
    return       [list $Fx $Fy $Epore]
}

## check this
proc EFmem {V0 z09 z } {
    set z9   [expr $z**9]
    set Emem [expr -$V0*$z09/$z9]
    set Fz   [expr -9*$V0*$z09/($z**10)]
    return   [list $Fz $Emem]
}

####
proc main {} {
global V0 rho02 z09 
    set out [open "Vpore.dat" w]
    puts $out "#rho   Energy  Fx  Fy"
    for {set i 0.01} {$i < 5} {set i [expr $i + 0.0001]} {
	set EF [EFpore $V0 $rho02 $i 0]
	puts $out "$i [lindex $EF 2] [lindex $EF 0] [lindex $EF 1]"
    }
    close $out
    set out [open "Vmem.dat" w]
    puts $out "#z    Energy  Fz"
    for {set i -0.5} {$i < -0.01} {set i [expr $i + 0.0001]} {
	set EF [EFmem $V0 $z09 $i]
	puts $out "$i [lindex $EF 1] [lindex $EF 0]"
    }
    close $out
}
####
main 

