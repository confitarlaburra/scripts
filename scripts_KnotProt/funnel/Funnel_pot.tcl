# EFpore: pore potential of a pore along the z axis whtih radius rho
# V0    :  Energy scaling factor
# rho02 :  pore radius squared
# rho2  :  radial distance squared
# x     :  x coordinate
# y     :  y coordinate
proc EFpore {V0 rho02 rho2 x y } {
    set ExpFact  [expr exp(1-($rho2)/($rho02))]
    set PlusFact [expr 1 + $ExpFact]
    set phi      [expr (2*$V0*$ExpFact)/($PlusFact*$PlusFact*$rho02)]
    set Fx       [expr -$phi*$x]
    set Fy       [expr -$phi*$y]
    addforce "$Fx $Fy 0"
}
# EFmem:  repulsive potential along the z axis, outside pore
# V0   :  Energy scaling factor
# z09  :  scaling factor 
# z    :  z coordinate
proc EFmem {V0 z09 z } {
    set z10   [expr $z**10]
    set Fz    [expr -9*$V0*$z09/$z10]
    addforce "0 0 $Fz"
}
# InterpolateRho0: Transform any interval into a 0-1 for linear interporlation:
# rho0Int        : (lambda)rho0N + (1-lambda)rho0W
# zvalue         : value along funnel axis
# rho0N          : radius of narrow section of funnel
# rho0W          : radius of wider section of funnel 
# min            : initial value (pore axis) of transition from the wide to the narrow 
# e.g.zWe  
# max            : final value (pore axis) of transition from the wide to the narrow 
# e.g.zNb  
proc InterpolateRho0 {zvalue rho0N rho0W min max} {
    set lambda   [expr ($zvalue-$min)/($max-$min)]
    set rho0Int  [expr (1-$lambda)*$rho0W + $lambda*$rho0N]
    return       [expr $rho0Int*$rho0Int] 
}
#caclforces: tclboundary potential
#step  : MD step
#unique: patch
# It has to be called calcforces and needs step and unique 
proc calcforces {step unique } {
    global V0 rho0W rho0N rho02W rho02N zN zWb zWe z09 
    # pick atoms of the given patch one by one
    while {[nextatom]} { 
	set rvec [getcoord] ;# get the atom's coordinates
	# get the components of the vector
	foreach { x y z } $rvec { break }
	set rho2 [expr $x*$x + $y*$y]
	#outside funnel
	if { $z <= $zWb && $rho2 > $rho02W } {
	    EFmem $V0 $z09 $z
	}
	#within wide section of funnel 
	if {$z > $zWb && $z < $zWe } {
	    EFpore $V0 $rho02W $rho2 $x $y
	}
	#within wider to narrow transition section
	if {$z >= $zWe && $z <= $zN } {
	    set rho0Int2 [InterpolateRho0 $z $rho0N $rho0W $zWe $zN]
	    EFpore $V0 $rho0Int2 $rho2 $x $y
	}
       	# within narrow section of the funnel
	if {$z > $zN } {
	    EFpore $V0 $rho02N $rho2 $x $y
	}
    }
}

