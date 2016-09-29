#!/usr/bin/perl



###OSP subroutine####

# @{$_[0]}  state A array
# @{$_[1]}  state R array (reference state)
# $_[2] temperature in kelvin

####
sub exp_OSP {
	my (@stateA) = @{$_[0]};
        my (@stateR) = @{$_[1]};
	my $T =$_[2];
	my $kb = 0.008314511212;
	my $kbT=$kb*$T; 
	my $size_x = @stateA;
	my $size_y = @stateR;	
	$exp_aver  = 0.0;
	@exp_avrgs = ();
	if ($size_x != $size_y) { print "values and bias must be the same size\n"; exit 1;}		
	for ($count = 0; $count < $size_x; $count++) {
		$exp_delta  = exp ((-($stateA[$count]-$stateR[$count] ) )/($kbT));
		push (@exp_avrgs,$exp_delta );
		$exp_aver         += $exp_delta;
	}
	$exp_aver =$exp_aver/$size_x;
	return ($exp_aver ,\@exp_avrgs);
}


###Main###

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ) {
    print "Usage of this script : timeseries_energy_state_A timeseries_energy_state_R\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]"); #timseries energy A  
open (FILE_2, "$ARGV[1]"); #timeseries energy reference

@Astate_array=();
@Rstate_array=();
$kb = 0.008314511212;
$T=298;
$kbT=$kb*$T;
$bool_line_1 = 0;
$bool_line_2 = 0;

##Read input file to fill energy arrays.

while (($line_1=<FILE_1>) && ($line_2=<FILE_2>)) {	
	if ($line_1=~/#/) {$bool_line_1 = 1;}
	
	if (($line_1=~/^\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_1 == 1)) {
                $energy_A =$1;
		#print "$energy_A\n"; 
		push(@Astate_array, $energy_A);

        }

	if ($line_2=~/#/) {$bool_line_2 = 1;}
	
	if (($line_2=~/^\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_2 == 1)) {
                $energy_R =$1;
		push(@Rstate_array, $energy_R);
        }

}

close FILE_1;
close FILE_2;

($exp_aver,$a)= &exp_OSP(\@Astate_array,\@Rstate_array,$T); 
@exp_avrg_array= @$a;
#print "$exp_aver\n";
#Dirty way to get error estimates using tcf (gromos program)
open (OUT_2, ">exp_avrg.dat");       ##exp(deltaH/kbt) timeseries  file

print OUT_2 "\# Timeseries of exp(deltaH/kbt) timeseries  file\n";
foreach (@exp_avrg_array) {
	print OUT_2 "$_ \n";	
}
close OUT_2;
system ("tcf \@files exp_avrg.dat \@distribution 1 > error_exp_avrg.dat");

open (FILE_1, "error_exp_avrg.dat"); #exp(deltaH/kbt) error  file
$bool_line_1 = 0;

while ($line_1=<FILE_1>) {

	if (($line_1=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_1 == 2)) {
                $error_exp_avrg =$1;
		$bool_line_1 =0;
        }
	if ( $line_1=~/^STATISTICS/) {$bool_line_1++;}	
	if ( $line_1=~/^#/) {$bool_line_1++;}
}

$error_propagation_OSP=($kbT*$error_exp_avrg)/$exp_aver;
$G_RA =-$kbT*log($exp_aver);
printf   "%10s %10s\n","# G_RA", "error";
printf   "%10.2f %10.2f\n",$G_RA, $error_propagation_OSP; 
	


