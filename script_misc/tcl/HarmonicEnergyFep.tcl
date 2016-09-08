proc harmonicTI {frame} {
     global CA_index_list CAnumber index EnergyList fit
     if {$fit eq yes} {fit_bigdcd top "protein and name CA"}
     
     set out [open Total_Harmonic_ts.dat a+]
     set TotalEnergy 0
     for {set i 1} {$i <= $CAnumber} {incr i} {          
           set TotalEnergy [expr $TotalEnergy + [harmonic "$index($i)" "$index($i)" 1 -1] ]     
     }
     
     lappend EnergyList $TotalEnergy
     puts $out "$frame $TotalEnergy"
     if {$frame % 100 == 0} {puts "$frame $TotalEnergy"}
     close $out
     set lamda 0.0
     #if {$frame % 3000 == 0} {}
     if {$frame == 11000 } {
         set out2  [open HarmonicTI.dat a+]
         #if {$frame == 3000}  {set lamda 0.000}
         if {$frame == 3000}  {set lamda 0.500}
         if {$frame == 6000}  {set lamda 0.750}
         if {$frame == 9000}  {set lamda 0.900}
         if {$frame == 12000} {set lamda 0.950}
         if {$frame == 15000} {set lamda 0.975}
         if {$frame == 11000} {set lamda 1.000} 
         set NumberElements [llength $EnergyList]
         set Average 0
	 foreach energy $EnergyList {
                 set Average [expr $Average + $energy]
         }
         set Average [expr $Average/$NumberElements]
         set sd 0
         foreach energy $EnergyList {
                  set sd [expr $sd + ($energy - $Average)*($energy - $Average)]
         }
         set sd [expr sqrt ($sd/$NumberElements)]
         puts $out2 "$frame $lamda $Average $sd"
         close $out2 
         set EnergyList {} 	
     }
}



if { $argc != 5 } {
        puts "HarmonicEnergyFEP.tcl script requires 3 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/COM_bsheet.tcl -args path/to/inputpsf path/to/inputdcd path/to/reference/pdb fit (yes/no) remove Com (yes/no) "
        puts "Please try again."
        exit        
}

set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]
set reference_pdb [lindex $argv 2]
set fit           [lindex $argv 3]
mol load psf $input_psf

set CA_index_list [[atomselect top "protein and name CA"] get index]
open HarmonicTI.dat w
open Total_Harmonic_ts.dat w
set EnergyList {}
set i 1
foreach index_CA $CA_index_list {        
        set index($i) "index $index_CA"
        incr i
}
set CAnumber [llength $CA_index_list]



animate read pdb $reference_pdb
source /home/jgarate/script/bigdcd.tcl
source /home/jgarate/script/procedures/fit_bigdcd.tcl
source /home/jgarate/script/procedures/harmonic.tcl
if {$fit eq yes} {source /home/jgarate/script/procedures/fit_bigdcd.tcl}

bigdcd harmonicTI $input_dcd 
