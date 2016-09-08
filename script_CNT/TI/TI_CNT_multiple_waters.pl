#!/usr/bin/perl
use Cwd;
use File::chdir;

## Generates a set of inputs files were waters were removed one  by one, in topologies and CNF until CNT is empty

# very shitty script please use with caution
#Topology must have first CNT and then the solute waters
# Run it with all these files in the cwd,
# 

# Input files
$topo ="CNT.5.5.3nm.infinite.13.SPC.top";
$cnf  ="eq_5.cnf";
$bin ="/home/common/GROMOS/prog/gromosXX_mpi/md_mpi";
$template ="/home/jgarate/libs_new_clust/mkscript_mms_mpi.lib";
#base IMD without : MULTIBATH and FORCE block, prepareds for the system with all waters
$imd ="TI_water_5.5.imd";

#Pertubed and restrained waters indexes
$pert_wt_indx= 261; #only change this
$H1=$pert_wt_indx+1;
$H2=$H1+1;
$rest_wt=$H2+1;
#force constant
$k=500;
#Number of solutes
$Total_solute=299; #change this
$Total_CNT =260; #change this
$total_waters=13; # change this
$first_water= $Total_CNT+3;
$last_water=$first_water + 3*($total_waters -1);
#Number of atoms
$Total_atoms =4094; #change this 


#Numbers in topology, water are after CNT (total solute water $waters_init -$waters_fina) 
$waters_final = 2; 
$waters_init = 14;
$old_waters_init = $waters_init;
$init = 14;
# Current working directory
$wd = getcwd;


### MAIN###
			
while ($waters_init >= $waters_final) {
    $real_number = $waters_init -1;
    $dir = "water_$real_number";
    if (-d $dir)
    {} else {
	system("mkdir", $dir);
    }
    $CWD = "$wd/$dir";
    # Reduce topologies and cnfs
    $atoms = "1-$waters_init:a";
    if ( $waters_init < $init ) {
	system("red_top \@topo ../$topo  \@atoms $atoms > $topo.$real_number.top");
	system("filter \@topo ../$topo \@traj ../$cnf  \@pbc r \@select a:a s:a \@reject $old_waters_init-$init:a > $cnf.$real_number.cnf");
	system("frameout \@topo  $topo.$real_number.top \@traj $cnf.$real_number.cnf    \@pbc r \@outformat pdb");
	system("tser \@topo $topo.$real_number.top  \@traj $cnf.$real_number.cnf \@pbc r \@prop \'d%2:OW;3:OW\' > distances.out ");
    } else { 
	system("cp ../$cnf ../$topo .");
	system("frameout \@topo  $topo \@traj $cnf    \@pbc r \@outformat pdb");
	system("tser \@topo $topo  \@traj $cnf \@pbc r \@prop \'d%2:OW;3:OW \' > distances.out");
    }
    open (PERT, ">perturbation.ptop");
    print PERT "TITLE\n water to dummy\nEND\nPERTATOMPARAM\n";
    print PERT "\# number of perturbed atoms\n3\n\#  ";
    print PERT "\#   NR RES NAME IAC(A) MASS(A)  CHARGE(A) IAC(B) MASS(B) CHARGE(B)   ALJ  ACRF\n";
    print PERT "$pert_wt_indx   2  OW   4   15.99940   -0.820     19   15.99940   0.00     1.0  1.0\n";
    print PERT "$H1   2  HW1  18   1.008000   0.410     19    1.008000  0.00     1.0  1.0\n";
    print PERT "$H2   2  HW1  18   1.008000   0.410     19    1.008000  0.00     1.0  1.0\nEND";
    close PERT;
    open (REST, ">dist.rest");
    print REST "TITLE\n water to dummy pert dist rest to next water \nEND\nPERTDISRESSPEC\n";
    print REST "\# DISH  DISC\n0.1   0.153\n";
    print REST "# i  j   k  l   type    i  j  k  l  type  n m    A_r0  A_w0  B_r0   B_w0  rah\n";
    print REST " $rest_wt 0  0  0  0   $pert_wt_indx  0 0 0 0  0 0    0.0   0.0   0.0    $k   0\nEND";
    close REST;
    open (MKS, ">TI_mk_script.arg");
	 if ( $waters_init < $init ) {
	     print MKS "\@sys            TI_water_$real_number
\@bin            $bin                
\@version         md++               
\@dir            /pool/jgarate/TUBES/5.5_small/TI_infinite/$dir
\@files               
  topo           $topo.$real_number.top
  pttopo        perturbation.ptop
  input         TI.imd
  coord         $cnf.$real_number.cnf 
  disres        dist.rest
\@template     $template
\@joblist        TI_joblist.list";
	} else {

	    print MKS "\@sys            TI_water_$real_number
\@bin            $bin                
\@version         md++               
\@dir            /pool/jgarate/TUBES/5.5_small/TI_infinite/$dir
\@files               
  topo           $topo
  pttopo        perturbation.ptop
  input         TI.imd
  coord         $cnf
  disres        dist.rest
\@template     $template
\@joblist        TI_joblist.list";

}
    close MKS;
    #print joblist (very dirty)
    system ("perl /home/jgarate/Gromos_Files/script_CNT/TI/print_TI_job_list.pl > TI_joblist.list");
    #open and print IMD
    # fix this:
    open (IN_IMD,"../$imd");
    open (OUT_IMD,"> TI.imd");
    while ($line=<IN_IMD>) {
	print OUT_IMD $line;	
    }
    
    print OUT_IMD "MULTIBATH
\# ALGORITHM:
\#      weak-coupling(0):      use weak-coupling scheme
\#      nose-hoover(1):        use Nose Hoover scheme
\#      nose-hoover-chains(2): use Nose Hoover chains scheme
\# NUM: number of chains in Nose Hoover chains scheme
\#      !! only specify NUM when needed !!
\# NBATHS: number of temperature baths to couple to
\#          ALGORITHM
                   0
\#  NBATHS
         2
\# TEMP0(1 ... NBATHS)  TAU(1 ... NBATHS)
        298     0.1      298     0.1     
\#   DOFSET: number of distiguishable sets of d.o.f.
         2
\# LAST(1 ... DOFSET)  COMBATH(1 ... DOFSET)  IRBATH(1 ... DOFSET)
   $Total_solute             1         1      $Total_atoms         2         2
END\n";

    if ( $waters_init !=  $waters_final) {
	print OUT_IMD "FORCE
\#      NTF array
\# bonds    angles    imp.     dihe     charge nonbonded
\# H        H         H        H
  0  0     1  1      1  1     1  1     1  1
\# NEGR    NRE(1)    NRE(2)    ...      NRE(NEGR)
     4    $Total_CNT    $first_water  $last_water   $Total_atoms
END\n";
    }

    if ( $waters_init ==  $waters_final) {
	print OUT_IMD "FORCE
\#      NTF array
\# bonds    angles    imp.     dihe     charge nonbonded
\# H        H         H        H
  0  0     1  1      1  1     1  1     1  1
\# NEGR    NRE(1)    NRE(2)    ...      NRE(NEGR)
     3    $Total_CNT    $first_water   $Total_atoms
END\n";
    }	

    close OUT_IMD;
    
    #system ("mk_script \@f TI_mk_script.arg" );


    $old_waters_init =$waters_init; 
    $waters_init--;
    $Total_solute-=3;
    $Total_atoms -=3;
    $last_water-=3;
    $CWD = "$wd";
}

