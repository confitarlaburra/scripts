set psfName H2O.psf
set dcdName eq1.dcd

set rho0N  15.0;   # Pore Radius of narrower section in x-y plane
set rho0W  30.0;   # Pore Radius of wider section in x-y plane			  
   
set zN    30.0;    # Narrow section begins in z
set zWb    0.0;    # Wider section begins in z
set zWe    15;     # Wider section ends   in z

set boxSizeZ 100
set funnelR  0.1;  # funnel resolution (just for drawing purpose)

#### procedures ######

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
    return       [expr $rho0Int] 
}


proc main { } {
global  psfName dcdName rho0N rho0W 
global  zN zWb zWe boxSizeZ funnelR
    
    mol load psf $psfName
    mol addfile $dcdName waitfor all
    pbc box -center origin
    
    #Draw wider section
    set vec1 "0 0 $zWb"
    set vec2 "0 0 $zWe"
    draw cylinder $vec1 $vec2 radius $rho0W
    
    #Draw funnel section
    set z $zWe
    while {$z < $zN } {
	set old_z $z
	set z [expr $z + $funnelR]
	set rho0Int [InterpolateRho0 $z $rho0N $rho0W $zWe $zN]
	set vec1 "0 0 $old_z"
	set vec2 "0 0 $z"
	draw cylinder $vec1  $vec2 radius $rho0Int
    }
    #Draw narrow section till the end of box
    set vec1 "0 0 $zN"
    set halfBoxZ [expr 0.5*$boxSizeZ]
    set vec2 "0 0 $halfBoxZ"
    draw cylinder $vec1  $vec2 radius $rho0N
}
## Run ###
main
