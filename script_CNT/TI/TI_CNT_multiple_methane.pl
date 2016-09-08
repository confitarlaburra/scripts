#!/usr/bin/perl

BEGIN {
 unshift @INC,"/home/jgarate/bin/perl_modules"

}


use Cwd;
use File::chdir;

## Generates a set of inputs files were waters were removed one  by one, in topologies and CNF until CNT is empty

# very shitty script please use with caution
#Topology must have first CNT and then the solute waters
# Run it with all these files in the cwd,
# 

# Input files
$topo ="9.CH4.6.6_3nm.topo";
$cnf  ="eq_CNT_9CH4_5.cnf";
$bin ="/opt/gromosXX/bin/md";
$template ="/home/jgarate/libraries/mkscript_mms_ateneav2.lib";
$Updir ="/home/jgarate/CNT_2013_2014/water_methane/6.6/periodic/";
$imd ="TI_water_6.6.imd";
#number of atoms in perturbed molecule
$numAtm="1";
#Pertubed and restrained waters indexes
$pert_indx= 1; #only change this
$rest_indx=$pert_indx+1;
#force constant
$k=500;
#Number of solutes
$Total_solute=321; #change this
$Total_CNT =321; #change this
$total_load=9; # change this
$first_load= $numAtm;
$last_load= $numAtm*($total_load);
#Number of atoms
$Total_atoms =4002; #change this 
$Ti_job_list="/home/jgarate/bin/script_CNT/TI/print_TI_job_list.pl";


#Numbers in topology, water are after CNT (total solute water $waters_init -$waters_fina) 
$load_final = 1; 
$load_init = 9;
$CNT_final=$load_init+1;
$old_load_init = $load_init;
$init = 9;
# Current working directory
$wd = getcwd;


### MAIN###
			
while ($load_init >= $load_final) {
    $real_number = $load_init ;
    $dir = "load_$real_number";
    if (-d $dir)
    {} else {
	system("mkdir", $dir);
    }
    $CWD = "$wd/$dir";
    # Reduce topologies and cnfs
    $atoms = "1-$load_init:a;$CNT_final:a";
    if ( $load_init != $init ) {
	system("red_top \@topo ../$topo  \@atoms \"$atoms\" > $topo.$real_number.top");
	system("filter \@topo ../$topo \@traj ../$cnf  \@pbc r \@select a:a s:a \@reject $old_load_init-$init:a > $cnf.$real_number.cnf\n");
	system("frameout \@topo  $topo.$real_number.top \@traj $cnf.$real_number.cnf    \@pbc r \@outformat pdb");
	system("tser \@topo $topo.$real_number.top  \@traj $cnf.$real_number.cnf \@pbc r \@prop \'d%va(com,1:a);va(com,2:a)\' > distances.out ");
    } else { 
	system("cp ../$cnf ../$topo .");
	system("frameout \@topo  $topo \@traj $cnf    \@pbc r \@outformat pdb");
	system("tser \@topo $topo  \@traj $cnf \@pbc r \@prop \'d%va(com,1:a);va(com,2:a)\' > distances.out ")
    }
    open (PERT, ">perturbation.ptop");
    print PERT "TITLE\n methane to dummy\nEND\nPERTATOMPARAM\n";
    print PERT "\# number of perturbed atoms\n$numAtm\n\#  ";
    print PERT "\#   NR RES NAME IAC(A) MASS(A)  CHARGE(A) IAC(B) MASS(B) CHARGE(B)   ALJ  ACRF\n";
    print PERT "$pert_indx   1  CM   15   16.043   0.0     19   16.043   0.00      1.0  1.0\n";
   # print PERT "$H1   2  HW1  18   1.008000   0.410     19    1.008000  0.00     1.0  1.0\n";
   # print PERT "$H2   2  HW1  18   1.008000   0.410     19    1.008000  0.00     1.0  1.0\nEND";
    print PERT "END";
    close PERT;
    open (REST, ">dist.rest");
    print REST "TITLE\n water to dummy pert dist rest to next water \nEND\nPERTDISRESSPEC\n";
    print REST "\# DISH  DISC\n0.1   0.153\n";
    print REST "# i  j   k  l   type    i  j  k  l  type  n m    A_r0  A_w0  B_r0   B_w0  rah\n";
    print REST " $rest_indx 0  0  0  0   $pert_indx  0 0 0 0  0 0    0.0   0.0   0.0    $k   0\nEND";
    close REST;
    open (MKS, ">TI_mk_script.arg");
     if ( $load_init != $init ) {
	print MKS "\@sys            TI_load_$real_number
\@bin            $bin                
\@version         md++               
\@dir            $Updir$dir
\@files               
  topo           $topo.$real_number.top
  pttopo        perturbation.ptop
  input         TI.imd
  coord         $cnf.$real_number.cnf 
  disres        dist.rest
\@template     $template
\@joblist        TI_joblist.list";
	} else {

	    print MKS "\@sys            TI_load_$real_number
\@bin            $bin                
\@version         md++               
\@dir            $Updir$dir
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
    system ("perl $Ti_job_list > TI_joblist.list");
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
                   2 3
\#  NBATHS
         3
\# TEMP0(1 ... NBATHS)  TAU(1 ... NBATHS)
        298     0.1      298     0.1    298 0.1     
\#   DOFSET: number of distiguishable sets of d.o.f.
         2
\# LAST(1 ... DOFSET)  COMBATH(1 ... DOFSET)  IRBATH(1 ... DOFSET)
   $Total_solute             1         2      $Total_atoms         3         3
END\n";

    if ( $load_init > 1) {
	print OUT_IMD "FORCE
\#      NTF array
\# bonds    angles    imp.     dihe     charge nonbonded
\# H        H         H        H
  0  0     1  1      1  1     1  1     1  1
\# NEGR    NRE(1)    NRE(2)    ...      NRE(NEGR)
     4    $first_load  $last_load   $Total_CNT $Total_atoms
END\n";
    } else  {
	print OUT_IMD "FORCE
\#      NTF array
\# bonds    angles    imp.     dihe     charge nonbonded
\# H        H         H        H
  0  0     1  1      1  1     1  1     1  1
\# NEGR    NRE(1)    NRE(2)    ...      NRE(NEGR)
     3     $first_load $Total_CNT   $Total_atoms
END\n";
    }	

    close OUT_IMD;
    
    #system ("mk_script \@f TI_mk_script.arg" );


    $old_load_init =$load_init; 
    $load_init--;
    $Total_solute-=$numAtm;
    $Total_atoms -=$numAtm;
    $Total_CNT-=$numAtm;
    $last_load-=$numAtm;
    $CWD = "$wd";
}

