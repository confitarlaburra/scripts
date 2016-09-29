#!/usr/bin/perl

#sub TrapInt input = 
# @{$_[0]} = x values (independet variable
# @{$_[1]} = y values (dependent variable)
# @{$_[2]} = error values for y (optional!!!)

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

$dh_dl_unbias  = 0.0;
$dh_dl_bias    = 0.0;
$error_bias    = 0.0;
$error_unbias  = 0.0;

@lambdas       =  ();
@dh_dls_bias   =  ();
@dh_dls_ubias  =  ();
@errors_bias   =  ();
@errors_unbias =  ();


open (OUT, "> DH_dl_dl_LE_TI_LC.dat");
printf OUT "%10s %10s %10s %10s %10s\n","#lambda", "<DH/dl b>","error b","<DH/dl u>","error u";
while ($lstart <= $lend+1e-8){
	$lstart = sprintf "%.1f", $lstart;
	$dir = "LE_TI_LC_${lstart}";
	#print "$dir\n";
	open (FILE_1, "$dir/ene_ana.out");
	open (FILE_2, "$dir/dvdl_unbias.dat");
	while ($line=<FILE_1>) {
		if ($line=~/dvdl\s+(\S+)\s+\S+\s+(\S+)/) {	 
			$dh_dl_bias =$1;
			$error_bias =$2; 	
		}
	}
	$bool_line2=0;
	while ($line2=<FILE_2>) {	
		if ( ($line2=~/\s+(\S+)\s+(\S+)/) && ($bool_line2==1) )  {
			$dh_dl_unbias = $1;
			$error_unbias = $2;
			$bool_line2=0;
		}
		if ($line2=~/^#/) {$bool_line2=1;}
	}
	push(@dh_dls_bias, $dh_dl_bias);
	push(@dh_dls_unbias, $dh_dl_unbias);
	push (@lambdas, $lstart);
	push (@errors_bias,$error_bias);
	push (@errors_unbias,$error_unbias);
	
	printf  OUT "%10.3f %10.3f %10.3f %10.3f %10.3f\n",$lstart, $dh_dl_bias, $error_bias,$dh_dl_unbias,$error_unbias;
	$lstart = $lstart+$ldelta;
}

($integral,$error) = &TrapInt(\@lambdas,\@dh_dls_bias,\@errors_bias);
printf "%10s %10s\n", "Integral bias","error bias";
printf "%10.3f %10.3f\n", $integral,$error;

($integral,$error) = &TrapInt(\@lambdas,\@dh_dls_unbias,\@errors_unbias);
printf "%10s %10s\n", "Integral unbias","error unbias";
printf "%10.3f %10.3f\n", $integral,$error;

close FILE_1;
close FILE_2;
close OUT;
