#!/usr/bin/perl



#### Main#####
## Reads ene_ana out with the dvdl (potentail energy) and returns integrated <dh/dl> + error ###
## Run it after ruanalysis.csh, in the main directory of the TI calculation ###
$lstart = 1.000;
$ldelta = 0.025;
$lend   = 1.000;
@lambdas=();
@dls=();
@errors   =  ();
$rmsd=  0.0;
$error= 0.0;
$dl=0.0;
$file = "DH_dl_pot.dat";
open (OUT, ">$file");
printf OUT "%10s %10s %10s %10s\n","#lambda", "<DH/dl>","error", "rmsd";

while ($lstart <= $lend+1e-8){
	$lstart = sprintf "%.3f", $lstart; # normally have to change this depending on the TI point (decimals)
	$dir = "L_${lstart}";
	if (-d $dir) {
		open (FILE_1, "$dir/ene_ana_pot.out");
		while ($line=<FILE_1>) {
			if ($line=~/dvdl\s+(\S+)\s+(\S+)\s+(\S+)/) {	 
				$dl ="$1";
				$dl =~s/\s+//g;
				$rmsd = $2;
				$rmsd =~s/\s+//g;
				$error =$3;
				$error =~s/\s+//g;
			}
		}
		push(@errors, $error);
		push(@dls, $dl);
		push (@lambdas, $lstart);
		printf  OUT "%10.3f %10.3f %10.3f %10.3f\n",$lstart, $dl, $error, $rmsd;
	}
	$lstart = $lstart+$ldelta;
}

($integral,$error) = &TrapInt(\@lambdas,\@dls,\@errors);

printf "%3s %3s\n", "Integral ","error";
printf "%3.3f     %3.3f\n", $integral,$error;
close FILE_1;
close OUT;
