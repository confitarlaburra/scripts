#!/usr/bin/perl

###Unbias subroutine####

# Input: 
# @{$_[0]} = array of values to be unbiased
# @{$_[1]} = array of biases;
# $_[3] = Temperature in kelvin
# Returns reweighted_average, values_exp(bias) avrg, exp(bias)_avrg ,@exp_avrgs (array with exp(bias) ts), @values_exp_avrg (array with value*exp(bias) ts),
# Typical usage :
	# ($average_unbiased,$value_exp_bias_avrg,$exp_bias_avrg,$a,$b)= &Unbias(\@quantity_array,\@bias_array,$T);
	# @exp_bias_array= @$a;
	# @value_exp_bias_array = @$b;

####################################################################################################

sub Unbias {
	my (@values) = @{$_[0]};
        my (@biases) = @{$_[1]};
	my $T =$_[2];
	my $kb = 0.008314511212;
	my $kbT=$kb*$T; 
	my $size_x = @values;
	my $size_y = @biases;	
	$exp_aver = 0.0;
	$value_exp_aver = 0.0;
	@values_exp_avrg   = ();
	@exp_avrgs         = ();
	if ($size_x != $size_y) { print "values and bias must be the same size\n"; exit 1;}		
	for ($count = 0; $count < $size_x; $count++) {
		my $bias_exp      = exp ($biases[$count]/($kbT));
		my $value_exp     = $values[$count]*$bias_exp;
		#my $value_exp     = $values[$count]*exp($biases[$count]/($kbT));
		push (@exp_avrgs,$bias_exp );
		push (@values_exp_avrg ,$value_exp );
		$exp_aver         += $bias_exp;
		$value_exp_aver   += $value_exp;
	}
	$exp_aver = $exp_aver/$size_x;
	$value_exp_aver =$value_exp_aver/$size_x;
	$reweighted_average = $value_exp_aver/$exp_aver;
	return ($reweighted_average, $value_exp_aver, $exp_aver, \@exp_avrgs,\@values_exp_avrg);
}


###Main###

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ) {
    print "Usage of this script : timeseries.file bias_ts.file\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]"); #timseries  file
open (FILE_2, "$ARGV[1]"); #bias file

@quantity_array=();
@bias_array=();
$T=298;
$bool_line_1 = 0;
$bool_line_2 = 0;

##Read input file to fill bias and values arrays.

while (($line_1=<FILE_1>) && ($line_2=<FILE_2>)) {	
	if ($line_1=~/^#/) {$bool_line_1 = 1;}
	
	if (($line_1=~/^\s+\S+\s+(\S+)/) && ($bool_line_1 == 1)) {
                $quantity =$1;
		push(@quantity_array, $quantity);

        }

	if ($line_2=~/^#/) {$bool_line_2 = 1;}
	
	if (($line_2=~/^\s+\S+\s+(\S+)/) && ($bool_line_2 == 1)) {
                $bias =$1;
		push(@bias_array, $bias);
        }

}

close FILE_1;
close FILE_2;


#Unbias the selected quantity and get arrays of exp(bias) and value*exp(bias)
($average_unbiased,$value_exp_bias_avrg,$exp_bias_avrg,$a,$b)= &Unbias(\@quantity_array,\@bias_array,$T);
@exp_bias_array= @$a;
@value_exp_bias_array = @$b;
#Dirty way to get error estimates using tcf (gromos program)
open (OUT_2, ">exp_bias.dat");       ##exp(bias) timeseries  file
open (OUT_3, ">value_exp_bias.dat"); #value*exp(bias) timeseries  file

print OUT_2 "\# Timeseries of exp(bias/kbT)\n";
foreach (@exp_bias_array) {
 	#printf OUT_2 "%.2f\n",$_;
	print OUT_2 "$_ \n";	
}

print OUT_3 "\# Timeseries of value*exp(bias/kbT)\n";
foreach (@value_exp_bias_array) {
 	#printf OUT_3 "%.2f\n",$_;
	print OUT_3 "$_ \n";
}  

close OUT_2;
close OUT_3;

system ("tcf \@files value_exp_bias.dat \@distribution 1 > error_exp_bias_value.dat");
system ("tcf \@files exp_bias.dat \@distribution 1 > error_exp_bias.dat");

#Get the errors from tcf output
open (FILE_1, "error_exp_bias_value.dat"); #value*exp(bias) error  file
open (FILE_2, "error_exp_bias.dat");       #exp(bias) error  file

$bool_line_1 = 0;
$bool_line_2 = 0;
while (($line_1=<FILE_1>) && ($line_2=<FILE_2>)) {

	if (($line_1=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_1 == 2)) {
                $error_value_exp_bias =$1;
		$bool_line_1 =0;
        }
	if ( $line_1=~/^STATISTICS/) {$bool_line_1++;}	
	if ( $line_1=~/^#/) {$bool_line_1++;}
	
	
	if (($line_2=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_2 == 2)) {
                $error_exp_bias =$1;
		$bool_line_2 =0;
        }
	if ( $line_2=~/^STATISTICS/) {$bool_line_2++;}
	if ( $line_2=~/^#/) {$bool_line_2++;}
}

$error_propagation = (abs($value_exp_bias_avrg/$exp_bias_avrg))*sqrt(($error_value_exp_bias/$value_exp_bias_avrg)**2 + ($error_exp_bias/$exp_bias_avrg)**2);

printf   "%10s %10s\n","# unbias average", "unbias error";
printf   "%10.2f %10.2f\n",$average_unbiased, $error_propagation;



