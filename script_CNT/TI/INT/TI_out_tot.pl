#!/usr/bin/perl

# TrapInt = Trapezoidal inetegration
# Usage   = ($integral,$error) = &TrapInt(\@x,\@y,\@y_errors) @x = ind. var. array , @y = dep. var. array, @y_error = error in y array
sub TrapInt {
	my (@x) = @{$_[0]};
        my (@y) = @{$_[1]};
	my (@error) = @{$_[2]};
	my $size_x = @x;
	my $size_y = @y;
	if ($size_x != $size_y) { print "x and y must be the same size"; exit 1;}		
	$integral= 0.0;
	$total_error=0.0;
	for ($count = 1; $count <= ($size_x -1); $count++) {
		#my $delta_x = $x[$count] - $x[$old];
		my $old = $count -1;
		$integral += ($x[$count] - $x[$old]) * ($y[$count] + $y[$old]);
		if(@error) { $total_error    += ($x[$count] - $x[$old])*sqrt(($error[$count]**2+$error[$old]**2)); }
	}
	$integral    *= 0.5;
	$total_error *= 0.5;
	
	if(@error) {return ($integral,$total_error);}
	else {return ($integral);}
}

#### Main#####
## Reads ene_ana out with the dvdl (potentail energy) and returns integrated <dh/dl> + error ###
## Run it after ruanalysis.csh, in the main directory of the TI calculation ###
$lstart = 0.000;
$ldelta = 0.012;
$lend   = 1.0;
@lambdas=();
@dls=();
@errors   =  ();
$rmsd=  0.0;
$error= 0.0;
$dl=0.0;
$file = "DH_dl_tot.dat";
open (OUT, ">$file");
printf OUT "%10s %10s %10s %10s\n","#lambda", "<DH/dl>","error", "rmsd";

@dirs = <L_*>;
foreach $dir (@dirs) {
    if (-d $dir) {
	open (FILE_1, "$dir/ene_ana_totfren.out");
	while ($line=<FILE_1>) {
	    if ($line=~/totfren\s+(\S+)\s+(\S+)\s+(\S+)/) {	 
		$dl ="$1";
		$dl =~s/\s+//g;
		$rmsd = $2;
		$rmsd =~s/\s+//g;
		$error =$3;
		$error =~s/\s+//g;
		if ($error == "nan") {
		    $error =0.0;
		}
	    }
	}
	push(@errors, $error);
	push(@dls, $dl);
	$dir =~ tr/L_//d;
	push (@lambdas, $dir);
	printf  OUT "%10.5f %10.3f %10.3f %10.3f\n",$dir, $dl, $error, $rmsd;
    }
    $lstart = $lstart+$ldelta;
}

($integral,$error) = &TrapInt(\@lambdas,\@dls,\@errors);
printf "%3s %3s\n", "Integral ","error";
printf "%3.3f     %3.3f\n", $integral,$error;
close FILE_1;
close OUT;
