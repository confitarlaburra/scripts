#!/usr/bin/tclsh
if { $argc != 3 } {
        puts "The rmsf_traj.tcl script requires 2 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/rmsf_traj.tcl -args path/to/inputpsf path/to/inputdcd"
        puts "Please try again."
        exit        
}

set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1] 

mol load psf $input_psf
mol addfile $input_dcd waitfor all

source /home/jgarate/script/procedures/fit.tcl
source /home/jgarate/script/procedures/rmsf_ca.tcl

fit top "segname MD2"

rmsf_CA top rmsf.dat 21 "segname MD2 and resid 126 and noh and not backbone"
#rmsf_CA top rmsf.dat 21 "segname MD2 and name  CA"
