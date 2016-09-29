#!/usr/bin/perl


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




###Main###

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ||  ($ARGV[2] eq "" ) ||  ($ARGV[3] eq "" ) ) {
    print "Usage of this script : (scatter quantity vs bias file)  bins min max\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]"); #quantity (e.g. angle)  vs bias  file

$bin_number = $ARGV[1];
$min  = $ARGV[2];
$max = $ARGV[3];
@values=();
@biases = ();
$T=298;
$kb = 0.008314511212;
$kbT=$kb*$T; 

##Read input file to fill bias and values arrays.

open (FILE_1, "$ARGV[0]");
while ($line=<FILE_1>) 
{
    if ($line=~/(\S+)\s+(\S+)/) 
    {
	my $value =$1;
	#print 	"$quantity\n";
	$value =~s/\s+//g;
	my $bias = $2;
	$bias =~s/\s+//g;
	#print "$bias\n";
	push (@biases, $bias);
	push (@values, $value);
    }
}
close FILE_1;


#Unbias the selected quantity and get array of exp(bias) and value*exp(bias)
($a)= &Unbias_bins(\@values, \@biases,$T,$bin_number,$min,$max);
#@bins_bias= @$a;
@bins= @$a;
# Unbin and calculate G
$bin_size = ($max-$min)/$bin_number;


printf   "%10s   %10s   %10s\n"  ,"# Reaction Coordinate", "Probability", "Free energy[kJ/mol]";

@y_values=(); #array for y values (bins)
for ($count = 0; $count < $bin_number; $count++) {
    my $unbin=  ($count + 0.5)*$bin_size + $min ; # unbinnig centered at the middle of the bin ($count +0.5)
    push (@y_values, $unbin);
}

#Integration of unbias histogram to normalize
($integral) = &TrapInt(\@y_values,\@bins);

for ($count = 0; $count < $bin_number; $count++) 
{
    #my $unbin=  ($count + 0.5)*$bin_size + $min ; # unbinnig centered at the middle of the bin ($count +0.5)
    my $G = -$kbT*log($bins[$count]);
    $bins[$count]/=$integral; #normalization
    #printf   "%10d             %10.5f    %10.2f\n","$unbin", "$bins[$count]","$G";
    printf   "%10d             %10.5f    %10.2f\n","$y_values[$count]", "$bins[$count]","$G";
}




