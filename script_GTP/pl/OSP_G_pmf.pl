#!/usr/bin/perl

### TO DO: Normalize distributions by divinding it by its integral#####


###OSP subroutine############################

# @{$_[0]}  state A array
# @{$_[1]}  state R array (reference state)
# $_[2] temperature in kelvin

#############################################
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
	@biases = ();
	if ($size_x != $size_y) { print "values and bias must be the same size\n"; exit 1;}		
	for ($count = 0; $count < $size_x; $count++) {
		$bias= -($stateA[$count]-$stateR[$count]);
		#print "$bias\n";
		push (@biases,$bias );
		$exp_delta  = exp ((-($stateA[$count]-$stateR[$count] ) )/($kbT));
		push (@exp_avrgs,$exp_delta );
		$exp_aver         += $exp_delta;
	}
	$exp_aver =$exp_aver/$size_x;
	return ($exp_aver ,\@exp_avrgs,\@biases);
}


###Unbias bins subroutine####
# Calculates the unbias probability of each bin
# Input: 
# @{$_[0]} = array of values to be unbiased
# @{$_[1]} = array of biases;
# $_[2] = Temperature in kelvin
# $_[3] = bin number
# $_[4] = min of values
# $_[5] = max of values
# How to use it :
# ($a)= &Unbias_bins(\@values, \@biases,$T,$bin_number,$min,$max);
# @bins_bias= @$a;
####################################################################################################

sub Unbias_bins {
    my (@values) = @{$_[0]};
    my (@biases) = @{$_[1]};
    my $T =$_[2];
    my $bin_number =$_[3];
    my $min = $_[4];
    my $max = $_[5];
    my $kb = 0.008314511212;
    my $kbT=$kb*$T;
    my $size_x = @values;
    my $size_y = @biases;
    @bins =();
    $exp_aver = 0.0;
    if ($size_x != $size_y) { print "values and bias must be the same size\n"; exit 1;}

    for ($count = 0; $count <= $size_x; $count++) {    
	my $bias_exp      = exp ($biases[$count]/($kbT));
	$exp_aver += $bias_exp;
	$step =  int(( ($values[$count]-$min)/(($max-$min)/($bin_number)) ));
	$bins[$step] += exp($biases[$count]/($kbT));	
    }
    $exp_aver = $exp_aver/  $size_x;
    for ($count = 0; $count < $bin_number; $count++) {
	$bins[$count] = ($bins[$count]/$size_x)/$exp_aver;
    }
    return ( \@bins);
    }



###Main###

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ||  ($ARGV[2] eq "" ) ||  ($ARGV[3] eq "" ) ||  ($ARGV[4] eq "" ) ||  ($ARGV[5] eq "" )) {
    print "Usage of this script : (timeseries energy A) (timeseries energy R) (timeseries quantity)   (bins) (min) (max)\n";
    exit 1; 
}


open (FILE_1, "$ARGV[0]"); #timseries energy A  
open (FILE_2, "$ARGV[1]"); #timeseries energy B
open (FILE_3, "$ARGV[2]"); #timeseries of quantity (eg. angle)
$bin_number = $ARGV[3];
$min  = $ARGV[4];
$max = $ARGV[5];
@Astate_array=();
@Rstate_array=();
@quantities_array=();
@syn_Astate=();
@anti_Astate=();
@syn_Rstate=();
@anti_Rstate=();
$kb = 0.008314511212;
$T=298;
$kbT=$kb*$T;
$bool_line_1 = 0;
$bool_line_2 = 0;
$bool_line_3 = 0;
##Read input files to fill energy and angle arrays.

while (($line_1=<FILE_1>) && ($line_2=<FILE_2>) && ($line_3=<FILE_3>)) {	
	if ($line_1=~/^#/) {$bool_line_1 = 1;}
	if (($line_1=~/^\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_1 == 1)) {
                $energy_A =$1;
		#print  "$energy_A\n";
		push(@Astate_array, $energy_A);
        }

	if ($line_2=~/^#/) {$bool_line_2 = 1;}
	if (($line_2=~/^\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_2 == 1)) {
                $energy_R =$1;
		#print  "$energy_R\n";
		push(@Rstate_array, $energy_R);
        }

	if ($line_3=~/^#/) {$bool_line_3 = 1;}
	if (($line_3=~/^\s+\S+\s+(\S+)/) && ($bool_line_3 == 1)) {
                $quantity =$1;
		#print  "$quantity\n";
		push(@quantities_array,$quantity );
        }
}


##Arrays for the syn and anti energies
$size = @quantities_array;
for ($count = 0; $count <= $size; $count++) {
	$angle = $quantities_array[$count];
	$energy_Astate =$Astate_array[$count];	
	$energy_Rstate =$Rstate_array[$count];
	if ( ($angle >=140 && $angle <= 340)) { #anti
		push (@anti_Astate, $energy_Astate);
		push (@anti_Rstate, $energy_Rstate);
	}
	if ( ($angle > 340 || $angle < 140)) {  # syn
		push (@syn_Astate, $energy_Astate);
		push (@syn_Rstate, $energy_Rstate);
	}	

}


close FILE_1;
close FILE_2;
close FILE_3;

##Calculate free energies#############################

# Full free energy difference between A and R
#Calculate free energy using the perturbation formula and get array of exp(-(deltaH)/kbt) and biases -(deltaH)
($exp_aver,$a,$b)= &exp_OSP(\@Astate_array,\@Rstate_array,$T); 
@exp_avrg_array= @$a;
@biases= @$b;

#Unbias the selected quantity (in bins) and get array of exp(bias) and value*exp(bias)
($a)= &Unbias_bins(\@quantities_array, \@biases,$T,$bin_number,$min,$max);
@bins_bias= @$a;
# Unbin and calculate PMFs and print it out to PMF.dat
open (OUT_2,"> PMF.dat");
$bin_size = ($max-$min)/$bin_number;
printf OUT_2  "%10s   %10s   %10s\n"  ,"# Reaction Coordinate", "Probability", "Free energy[kJ/mol]";
for ($count = 0; $count < $bin_number; $count++) {
    my $unbin=  ($count + 0.5)*$bin_size + $min ; # unbinnig centered at the middle of the bin ($count +0.5)
    my $G = -$kbT*log($bins[$count]);
    printf OUT_2  "%10d             %10.5f    %10.2f\n","$unbin", "$bins[$count]","$G";
}
close OUT_2;
#######################################################################################


#Dirty way to get error estimates using tcf (gromos++ program)
open (OUT_2, ">exp_avrg.dat");       ##exp(deltaH/kbt) timeseries  file

print OUT_2 "\# Timeseries of exp(deltaH/kbt) timeseries file \n";
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
printf   "%10s %10s\n","# Total G_RA", "error";
printf   "%10.2f %10.2f\n",$G_RA, $error_propagation_OSP; 
####################################################################################	

# anti free energy difference between A and R
#Calculate free energy using the perturbation formula and get array of exp(-(deltaH)/kbt) and biases -(deltaH)
($exp_aver,$a,$b)= &exp_OSP(\@anti_Astate,\@anti_Rstate,$T); 
@exp_avrg_array= @$a;
@biases= @$b;
#Dirty way to get error estimates using tcf (gromos++ program)
open (OUT_2, ">exp_avrg.dat");       ##exp(deltaH/kbt) timeseries  file

print OUT_2 "\# Timeseries of exp(deltaH/kbt) timeseries file \n";
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
printf   "%10s %10s\n","# G_RA anti", "error";
printf   "%10.2f %10.2f\n",$G_RA, $error_propagation_OSP; 
###############################################################################################################

# syn free energy difference between A and R
#Calculate free energy using the perturbation formula and get array of exp(-(deltaH)/kbt) and biases -(deltaH)
($exp_aver,$a,$b)= &exp_OSP(\@syn_Astate,\@syn_Rstate,$T); 
@exp_avrg_array= @$a;
@biases= @$b;
#Dirty way to get error estimates using tcf (gromos++ program)
open (OUT_2, ">exp_avrg.dat");       ##exp(deltaH/kbt) timeseries  file

print OUT_2 "\# Timeseries of exp(deltaH/kbt) timeseries file \n";
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
printf   "%10s %10s\n","# G_RA syn", "error";
printf   "%10.2f %10.2f\n",$G_RA, $error_propagation_OSP;

