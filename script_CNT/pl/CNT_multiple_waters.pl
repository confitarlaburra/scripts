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
$bin ="/home/common/GROMOS/prog/gromosXX_gpu/md";
$template ="/home/jgarate/libs_new_clust/mkscript_cuda.lib";
#base IMD without : MULTIBATH and FORCE block, prepared for the system with all waters
$imd ="Water_5.5.imd";
#number of simulations 
$nsim=100;
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
			
while ($waters_init >= ($waters_final-1)) {
    $real_number = $waters_init -1;
    $dir = "L00_$real_number";
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
    open (MKS, ">TI_mk_script.arg");
	 if ( $waters_init < $init ) {
	     print MKS "\@sys            water_$real_number
\@bin            $bin                
\@version         md++               
\@dir            /pool/jgarate/TUBES/5.5_small/TI_infinite/$dir   
\@files               
  topo           $topo.$real_number.top
  input         md.imd
  coord         $cnf.$real_number.cnf 
\@template     $template
\@script 1 $nsim";
	} else {

	    print MKS "\@sys            water_$real_number
\@bin            $bin                
\@version         md++               
\@dir            /pool/jgarate/TUBES/5.5_small/TI_infinite/$dir
\@files               
  topo           $topo
  input         md.imd
  coord         $cnf
\@template     $template
\@script         1 $nsim";

}
    close MKS;
    #print joblist (very dirty)
    #system ("perl /home/jgarate/Gromos_Files/script_CNT/TI/print_TI_job_list.pl > TI_joblist.list");
    #open and print IMD
    # fix this:
    open (IN_IMD,"../$imd");
    open (OUT_IMD,"> md.imd");
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
        298  0.1  298     0.1      298     0.1     
\#   DOFSET: number of distiguishable sets of d.o.f.
         3
\# LAST(1 ... DOFSET)  COMBATH(1 ... DOFSET)  IRBATH(1 ... DOFSET)
   $Total_CNT 1   2   $last_water 1  2         $Total_atoms         3         3
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

