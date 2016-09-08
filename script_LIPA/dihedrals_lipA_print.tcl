proc dihedral { frame } {
       global Dihed SkipFrames numframes
	
   if {$frame >= $SkipFrames} {
       for {set i 1} {$i <= 13} {incr i} {
           set  DihedAngle($i) [measure dihed $Dihed($i)]
           if   {$DihedAngle($i) < 0} {
        	set DihedAngle($i) [expr $DihedAngle($i) + 360] 
	   }
       }

      set out1 [open GlicosidicDihed.out a+]
      puts $out1 "$frame $DihedAngle(1) $DihedAngle(2) $DihedAngle(3)"
      close $out1
      set out2 [open SugarA.out a+]
      puts $out2 "$frame $DihedAngle(4) $DihedAngle(5) $DihedAngle(6)"
      close $out2
      set out3 [open SugarB.out a+]
      puts $out3 "$frame $DihedAngle(7) $DihedAngle(8) $DihedAngle(9)"
      close $out3
      set out4 [open SugarLipidA.out a+]
      puts $out4 "$frame $DihedAngle(10) $DihedAngle(11)"
      close $out4
      set out5 [open SugarLipidB.out a+]
      puts $out5 "$frame $DihedAngle(12) $DihedAngle(13)"
      close $out4

  }
  if {$frame % 100 == 0} {
   puts "$frame $DihedAngle(1)"	 
  }

  if {$frame == $numframes} {
     set bfile [open bfile w]

	puts $bfile "#Obligatory descriptive comment\nsubtitle \"Sugar A a1 a2 a3\"\nLEGEND CHAR SIZE 0.83\nLEGEND BOX FILL off\nLEGEND BOX COLOR 0\nxaxis label \"time (ps)\"\nyaxis label \"Degrees\"\nxaxis  tick major 2000\nyaxis tick major 10\nxaxis  tick place normal\nyaxis  tick place normal \ns0.y = s0.y -180\ns1.y = s1.y -180\ns2.y = s2.y -180\nWORLD XMIN 0\nWORLD XMAX $numframes\nWORLD YMIN -70\nWORLD YMAX 0\n s0 line color 1 \n s1 line color 2 \n s2 line color 7\n s0 legend \"a1\"\n s1 legend \"a2\" \n s2 legend \"a3\" "
	close $bfile
	exec gracebat -block SugarA.out -settype xy -bxy 1:2 -block SugarA.out -settype xy -bxy 1:3 -block SugarA.out -settype xy -bxy 1:4 -batch bfile -saveall Sugar_A_a1_a2_a3.agr

	#exec ps2pdf Sugar_A_a1_a2_a3.ps 

	set bfile [open bfile w]

	puts $bfile "#Obligatory descriptive comment\nsubtitle \"Sugar B a1 a2 a3\"\nLEGEND CHAR SIZE 0.83\nLEGEND BOX FILL off\nLEGEND BOX COLOR 0\nxaxis label \"time (ps)\"\nyaxis label \"Degrees\"\nxaxis  tick major 2000\nyaxis tick major 10\nxaxis  tick place normal\nyaxis  tick place normal \ns0.y = s0.y -180\ns1.y = s1.y -180\ns2.y = s2.y -180\nWORLD XMIN 0\nWORLD XMAX $numframes\nWORLD YMIN -70\nWORLD YMAX 0\n s0 line color 1 \n s1 line color 2 \n s2 line color 7\n s0 legend \"a1\" \n s1 legend \"a2\" \n s2 legend \"a3\" "

	close $bfile

	exec gracebat -block SugarB.out -settype xy -bxy 1:2 -block SugarB.out -settype xy -bxy 1:3 -block SugarB.out -settype xy -bxy 1:4 -batch bfile -saveall Sugar_B_a1_a2_a3.agr

	#exec ps2pdf Sugar_B_a1_a2_a3.ps

	set bfile [open bfile w]

	puts $bfile "#Obligatory descriptive comment\nsubtitle \"C1 O1 C12 C12\"\nLEGEND CHAR SIZE 0.83\nLEGEND BOX FILL off\nLEGEND BOX COLOR 0\nxaxis label \"time (ps)\"\nyaxis label \"Degrees\"\nxaxis  tick major 2000\nyaxis tick major 20\nxaxis  tick place normal\nyaxis  tick place normal\nWORLD XMIN 0\nWORLD XMAX $numframes"

	close $bfile

	exec gracebat -block GlicosidicDihed.out -settype xy -bxy 1:2 -batch bfile -saveall C1_O1_C12_C11.agr 

	#exec ps2pdf C1_O1_C12_C11.ps


	set bfile [open bfile w]

	puts $bfile "#Obligatory descriptive comment\nsubtitle \"O1 C12 C11 C10\"\nLEGEND CHAR SIZE 0.83\nLEGEND BOX FILL off\nLEGEND BOX COLOR 0\nxaxis label \"time (ps)\"\nyaxis label \"Degrees\"\nxaxis  tick major 2000\nyaxis tick major 20\nxaxis  tick place normal\nyaxis  tick place normal\nWORLD XMIN 0\nWORLD XMAX $numframes"

	close $bfile

	exec gracebat -block GlicosidicDihed.out -settype xy -bxy 1:3 -batch bfile -saveall O1_C12_C11_C10.agr 

	#exec ps2pdf O1_C12_C11_C10.ps


	set bfile [open bfile w]

	puts $bfile "#Obligatory descriptive comment\nsubtitle \"C2 C1 O1 C12\"\nLEGEND CHAR SIZE 0.83\nLEGEND BOX FILL off\nLEGEND BOX COLOR 0\nxaxis label \"time (ps)\"\nyaxis label \"Degrees\"\nxaxis  tick major 2000\nyaxis tick major 20\nxaxis  tick place normal\nyaxis  tick place normal\nWORLD XMIN 0\nWORLD XMAX $numframes"

	close $bfile

	exec gracebat -block GlicosidicDihed.out -settype xy -bxy 1:4 -batch bfile -saveall C2_C1_O1_C12.agr 

	#exec ps2pdf C2_C1_O1_C12.ps

	set bfile [open bfile w]
	puts $bfile "#Obligatory descriptive comment\nsubtitle \"C3 O3 C13 C14\"\nLEGEND CHAR SIZE 0.83\nLEGEND BOX FILL off\nLEGEND BOX COLOR 0\nxaxis label \"time (ps)\"\nyaxis label \"Degrees\"\nxaxis  tick major 2000\nyaxis tick major 20\nxaxis  tick place normal\nyaxis  tick place normal\nWORLD XMIN 0\nWORLD XMAX $numframes"

	close $bfile

	exec gracebat -block SugarLipidA.out -settype xy -bxy 1:2 -batch bfile -saveall C3_O3_C13_C14.agr 

	#exec ps2pdf C3_O3_C13_C14.ps

	set bfile [open bfile w]
	puts $bfile "#Obligatory descriptive comment\nsubtitle \"C2 N2 C41 C42\"\nLEGEND CHAR SIZE 0.83\nLEGEND BOX FILL off\nLEGEND BOX COLOR 0\nxaxis label \"time (ps)\"\nyaxis label \"Degrees\"\nxaxis  tick major 2000\nyaxis tick major 20\nxaxis  tick place normal\nyaxis  tick place normal\nWORLD XMIN 0\nWORLD XMAX $numframes"

	close $bfile

	exec gracebat -block SugarLipidA.out -settype xy -bxy 1:3 -batch bfile -saveall C2_N2_C41_C42.agr 

	#exec ps2pdf C2_N2_C41_C42.ps

	set bfile [open bfile w]
	puts $bfile "#Obligatory descriptive comment\nsubtitle \"C9 O9 C67 C68\"\nLEGEND CHAR SIZE 0.83\nLEGEND BOX FILL off\nLEGEND BOX COLOR 0\nxaxis label \"time (ps)\"\nyaxis label \"Degrees\"\nxaxis  tick major 2000\nyaxis tick major 20\nxaxis  tick place normal\nyaxis  tick place normal\nWORLD XMIN 0\nWORLD XMAX $numframes"

	close $bfile

	exec gracebat -block SugarLipidB.out -settype xy -bxy 1:2 -batch bfile -saveall C9_O9_C67_C68.agr 

	#exec ps2pdf C9_O9_C67_C68.ps

        set bfile [open bfile w]
	
        puts $bfile "#Obligatory descriptive comment\nsubtitle \"C8 N8 C81 C82\"\nLEGEND CHAR SIZE 0.83\nLEGEND BOX FILL off\nLEGEND BOX COLOR 0\nxaxis label \"time (ps)\"\nyaxis label \"Degrees\"\nxaxis  tick major 2000\nyaxis tick major 20\nxaxis  tick place normal\nyaxis  tick place normal\nWORLD XMIN 0\nWORLD XMAX $numframes"

	close $bfile

	exec gracebat -block SugarLipidB.out -settype xy -bxy 1:3 -batch bfile -saveall C8_N8_C81_C82.agr 

	#exec ps2pdf C8_N8_C81_C82.ps

    

}


}

if { $argc != 6 } {
        puts "The dihedrals.tcl script requires 5 variables  to be inputed."
        puts "For example, vmd -dispdev text -e path/to/dihedral.tcl -args path/to/inputpsf path/to/inputdcd numframes skipframes lipid "
        puts "Please try again."
        exit        
}


set input_psf     [lindex $argv 0]
set input_dcd     [lindex $argv 1]    
set numframes     [lindex $argv 2]
set SkipFrames    [lindex $argv 3]
set lipid         [lindex $argv 4]
#set lipid LIIV
puts "$lipid la que cuelga"

open GlicosidicDihed.out w
open SugarA.out w
open SugarB.out w
open SugarLipidA.out w
open SugarLipidB.out w


mol load psf $input_psf

for {set i 1} {$i <= 12} {incr i} {
     set C$i [[atomselect top "resname $lipid and name C$i"] get index]
     set O$i [[atomselect top "resname $lipid and name O$i"] get index]
}

foreach n {13 14 41 42 67 68 81 82} {
	set C$n [[atomselect top "resname $lipid and name C$n"] get index]
}
foreach n {2 8} {
	set N$n [[atomselect top "resname $lipid and name N$n"] get index]
}

for {set i 1} {$i <= 13} {incr i} {
    set Dihed($i) {}
}


#Dihedrals glicosidic linkage

# Dihed1 C1 O1 C12 C11
lappend Dihed(1) $C1
lappend Dihed(1) $O1
lappend Dihed(1) $C12
lappend Dihed(1) $C11
# Dihed2  O1 C12 C11 C10
lappend Dihed(2) $O1
lappend Dihed(2) $C12
lappend Dihed(2) $C11
lappend Dihed(2) $C10
# Dihed3  C2 C1 O1 C12
lappend Dihed(3) $C2	
lappend Dihed(3) $C1
lappend Dihed(3) $O1
lappend Dihed(3) $C12

#Dihedrals for the sugar rings

# Dihed4  C4  O5  C2 C1 , alpha1 sugar A
lappend Dihed(4) $C4
lappend Dihed(4) $O5
lappend Dihed(4) $C2
lappend Dihed(4) $C1
# Dihed5 O5  C2 C4 C3 , alpha2 sugar A
lappend Dihed(5) $O5
lappend Dihed(5) $C2
lappend Dihed(5) $C4
lappend Dihed(5) $C3
# Dihed6 C2 C4 O5 C5 alpha3 sugar A
lappend Dihed(6) $C2
lappend Dihed(6) $C4
lappend Dihed(6) $O5
lappend Dihed(6) $C5
# Dihed7 C10 O11 C8 C7   alpha1 sugar B
lappend Dihed(7) $C10
lappend Dihed(7) $O11
lappend Dihed(7) $C8
lappend Dihed(7) $C7
# Dihed8 O11 C8 C10 C9 , alpha2 sugar B
lappend Dihed(8) $O11
lappend Dihed(8) $C8
lappend Dihed(8) $C10
lappend Dihed(8) $C9
# Dihed9 C8 C10 O11 C11,    alpha3 sugar B
lappend Dihed(9) $C8
lappend Dihed(9) $C10
lappend Dihed(9) $O11
lappend Dihed(9) $C11

#Dihedrals sugars lipids

# Dihed10 C3 O3 C13 C14
lappend Dihed(10) $C3
lappend Dihed(10) $O3
lappend Dihed(10) $C13
lappend Dihed(10) $C14
# Dihed11 C2 N2 C41 C42
lappend Dihed(11) $C2
lappend Dihed(11) $N2
lappend Dihed(11) $C41
lappend Dihed(11) $C42
# Dihed12 C9 O9 C67 C68
lappend Dihed(12) $C9
lappend Dihed(12) $O9
lappend Dihed(12) $C67
lappend Dihed(12) $C68
# Dihed13 C8 N8 C81 C82
lappend Dihed(13) $C8
lappend Dihed(13) $N8
lappend Dihed(13) $C81
lappend Dihed(13) $C82

source /home/jgarate/script/bigdcd.tcl
bigdcd dihedral $input_dcd


