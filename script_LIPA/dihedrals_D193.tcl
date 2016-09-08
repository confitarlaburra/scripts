proc dihedral { frame } {
       global Dihed SkipFrames
	
   if {$frame >= $SkipFrames} {
       for {set i 1} {$i <= 12} {incr i} {
           set  DihedAngle($i) [measure dihed $Dihed($i)]
           if   {$DihedAngle($i) < 0} {
        	set DihedAngle($i) [expr $DihedAngle($i) + 360] 
	   }
       }

      set out1 [open GlicosidicDihed.out a+]
      puts $out1 "$frame $DihedAngle(1) $DihedAngle(2)"
      close $out1
      set out2 [open SugarA.out a+]
      puts $out2 "$frame $DihedAngle(3) $DihedAngle(4) $DihedAngle(5)"
      close $out2
      set out3 [open SugarB.out a+]
      puts $out3 "$frame $DihedAngle(6) $DihedAngle(7) $DihedAngle(8)"
      close $out3
      set out4 [open SugarLipidA.out a+]
      puts $out4 "$frame $DihedAngle(9) $DihedAngle(10)"
      close $out4
      set out5 [open SugarLipidB.out a+]
      puts $out5 "$frame $DihedAngle(11) $DihedAngle(12)"
      close $out4

  }
  if {$frame % 100 == 0} {
   puts "$frame $DihedAngle(1)"	 
  }

}



set input_psf DA193.solv.box.ion.psf
set input_dcd eq4.dcd
set SkipFrames 0
open GlicosidicDihed.out w
open SugarA.out w
open SugarB.out w
open SugarLipidA.out w
open SugarLipidB.out w

mol load psf $input_psf

for {set i 1} {$i <= 12} {incr i} {
     set C$i [[atomselect top "resname D193 and name C$i"] get index]
     set O$i [[atomselect top "resname D193 and name O$i"] get index]
}

foreach n {13 14 41 42 67 68 81 82} {
	set C$n [[atomselect top "resname D193 and name C$n"] get index]
}
foreach n {2 8} {
	set N$n [[atomselect top "resname D193 and name N$n"] get index]
}

for {set i 1} {$i <= 12} {incr i} {
    set Dihed($i) {}
}


#Dihedrals glicosidic linkage

# Dihed1 C1 O1 C12 C11
lappend Dihed(1) $C1
lappend Dihed(1) $O1
lappend Dihed(1) $C10
lappend Dihed(1) $O11
# Dihed2  C2 C1 O1 C12
lappend Dihed(2) $C2	
lappend Dihed(2) $C1
lappend Dihed(2) $O1
lappend Dihed(2) $C10

#Dihedrals for the sugar rings

# Dihed4  C4  O5  C2 C1 , alpha1 sugar A
lappend Dihed(3) $C4
lappend Dihed(3) $O5
lappend Dihed(3) $C2
lappend Dihed(3) $C1
# Dihed5 O5  C2 C4 C3 , alpha2 sugar A
lappend Dihed(4) $O5
lappend Dihed(4) $C2
lappend Dihed(4) $C4
lappend Dihed(4) $C3
# Dihed6 C2 C4 O5 C5 alpha3 sugar A
lappend Dihed(5) $C2
lappend Dihed(5) $C4
lappend Dihed(5) $O5
lappend Dihed(5) $C5
# Dihed7 C10 O11 C8 C7   alpha1 sugar B
lappend Dihed(6) $C10
lappend Dihed(6) $O11
lappend Dihed(6) $C8
lappend Dihed(6) $C7
# Dihed8 O11 C8 C10 C9 , alpha2 sugar B
lappend Dihed(7) $O11
lappend Dihed(7) $C8
lappend Dihed(7) $C10
lappend Dihed(7) $C9
# Dihed9 C8 C10 O11 C11,    alpha3 sugar B
lappend Dihed(8) $C8
lappend Dihed(8) $C10
lappend Dihed(8) $O11
lappend Dihed(8) $C11

#Dihedrals sugars lipids

# Dihed10 C3 O3 C13 C14
lappend Dihed(9) $C3
lappend Dihed(9) $O3
lappend Dihed(9) $C13
lappend Dihed(9) $C14
# Dihed11 C2 N2 C41 C42
lappend Dihed(10) $C2
lappend Dihed(10) $N2
lappend Dihed(10) $C41
lappend Dihed(10) $C42
# Dihed12 C9 O9 C67 C68
lappend Dihed(11) $C9
lappend Dihed(11) $O9
lappend Dihed(11) $C67
lappend Dihed(11) $C68
# Dihed13 C8 N8 C81 C82
lappend Dihed(12) $C8
lappend Dihed(12) $N8
lappend Dihed(12) $C81
lappend Dihed(12) $C82

source /home/jgarate/script/bigdcd.tcl
bigdcd dihedral $input_dcd
