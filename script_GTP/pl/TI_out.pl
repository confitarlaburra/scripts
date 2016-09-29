#!/usr/bin/perl


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
$lstart = 0.0;
$ldelta = 0.1;
$lend   = 1.0;
@lambdas=();
@dls=();
@errors   =  ();
$rmsd=  0.0;
$error= 0.0;
$dl=0.0;
open (OUT, "> DH_dl_dl.dat");
printf OUT "%10s %10s %10s %10s\n","#lambda", "<DH/dl>","error", "rmsd";
while ($lstart <= $lend+1e-8){
	$lstart = sprintf "%.1f", $lstart;
	$dir = "L_${lstart}";
	#print "$dir\n";
	open (FILE_1, "$dir/ene_ana.out");
	while ($line=<FILE_1>) {
		#print "$line";
		if ($line=~/dvdl\s+(\S+)\s+(\S+)\s+(\S+)/) {	 
			$dl ="$1";
			$dl =~s/\s+//g;
			#$dl = sprintf "%3.3f", $dl;
			#print "$dl\n";
			$rmsd = $2;
			$rmsd =~s/\s+//g;
			#$rmsd = sprintf "%3.3f", $rmsd;
			$error =$3;
			$error =~s/\s+//g;
			#$error = sprintf "%3.3f", $error;		
		}
	}
	push(@errors, $error);
	push(@dls, $dl);
	push (@lambdas, $lstart);
	
	printf  OUT "%10.3f %10.3f %10.3f %10.3f\n",$lstart, $dl, $error, $rmsd;
	$lstart = $lstart+$ldelta;
}

($integral,$error) = &TrapInt(\@lambdas,\@dls,\@errors);

printf "%3s %3s\n", "Integral ","error";
printf "%3.3f     %3.3f\n", $integral,$error;
close FILE_1;
close OUT;
