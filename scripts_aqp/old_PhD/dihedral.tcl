proc dihedral { frame } {
	foreach chain {A B C D} {
		global R216$chain H201$chain F077$chain
	}
	
	set R216A_dihe [measure dihed $R216A]
	set R216B_dihe [measure dihed $R216B]
	set R216C_dihe [measure dihed $R216C]
	set R216D_dihe [measure dihed $R216D]
	if {$R216A_dihe < 0} {
		set R216A_dihe [expr $R216A_dihe + 360]
	}

	if {$R216B_dihe < 0} {
                set R216B_dihe [expr $R216B_dihe + 360]
        }

	if {$R216C_dihe < 0} {
                set R216C_dihe [expr $R216C_dihe + 360]
        }

	if {$R216D_dihe < 0} {
                set R216D_dihe [expr $R216D_dihe + 360]
        }
	set out1 [open R216.out a+]
	puts $out1 "$frame $R216A_dihe $R216B_dihe $R216C_dihe $R216D_dihe"
	close $out1

	set H201A_dihe [measure dihed $H201A]
	set H201B_dihe [measure dihed $H201B]
	set H201C_dihe [measure dihed $H201C]
	set H201D_dihe [measure dihed $H201D]
	
	if {$H201A_dihe < 0} {
                set H201A_dihe [expr $H201A_dihe + 360]
        }

	if {$H201B_dihe < 0} {
                set H201B_dihe [expr $H201B_dihe + 360]
        }

	if {$H201C_dihe < 0} {
                set H201C_dihe [expr $H201C_dihe + 360]
        }

	if {$H201D_dihe < 0} {
                set H201D_dihe [expr $H201D_dihe + 360]
        }
	set out2 [open H201.out a+]
	puts $out2 "$frame $H201A_dihe $H201B_dihe $H201C_dihe $H201D_dihe"
	close $out2
	
	set F077A_dihe [measure dihed $F077A]
	set F077B_dihe [measure dihed $F077B]
	set F077C_dihe [measure dihed $F077C]
	set F077D_dihe [measure dihed $F077D]

	if {$F077A_dihe < 0} {
                set F077A_dihe [expr $F077A_dihe + 360]
        }

	if {$F077B_dihe < 0} {
                set F077B_dihe [expr $F077B_dihe + 360]
        }

	if {$F077C_dihe < 0} {
                set F077C_dihe [expr $F077C_dihe + 360]
        }

	if {$F077D_dihe < 0} {
                set F077D_dihe [expr $F077D_dihe + 360]
        }



	set out3 [open F077.out a+]
	puts $out3 "$frame $F077A_dihe $F077B_dihe $F077C_dihe $F077D_dihe"
	close $out3
	
	if {$frame % 100 == 0} {
		puts "$frame $R216A_dihe $R216B_dihe $R216C_dihe $R216D_dihe" 
	}
	
}





set input_psf ../AQP_cw_pope_wi.psf 
set input_dcd ../AQP4_zero.dcd
open R216.out w
open H201.out w
open F077.out w
mol load psf $input_psf

set R216A {40852 40855 40858 40861}
set R216B {44388 44391 44394 44397}
set R216C {47924 47927 47930 47933}
set R216D {51460 51463 51466 51469}

set H201A {40646 40633 40635 40640}
set H201B {44182 44169 44171 44176}
set H201C {47718 47705 47707 47712}
set H201D {51254 51241 51243 51248}

set F077A {38815 38817 38820 38821}
set F077B {42351 42353 42356 42357}
set F077C {45887 45889 45892 45893}
set F077D {49423 49425 49428 49429}


source bigdcd.tcl
bigdcd dihedral $input_dcd
