set TOL   -3.0;   # test optimal value, tolreance fistance to dropatoms 
set update 50; # test optimal value, update the considered atoms

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
#caclforces: tclboundary potential
#step  : MD step
#unique: patch
# It has to be called calcforces and needs step and unique 
proc calcforces {step unique } {
    global V0 rho02 z09 TOL update
    # pick atoms of the given patch one by one
    if { $step % $update == 0 } { cleardrops }
    while {[nextatom]} { 
	set rvec [getcoord] ;# get the atom's coordinates
	# get the components of the vector
	foreach { x y z } $rvec { break }
	if {$z < $TOL } {dropatom }; # no longer consider this atom until "cleardrop" 
	set rho2 [expr $x*$x + $y*$y]
	if {$z > 0 } {
	    EFpore $V0 $rho02 $rho2 $x $y
	}
	if { $z < 0 && $rho2 > $rho02 } {
	    EFmem $V0 $z09 $z
	}
    }
}

