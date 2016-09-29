#!/usr/bin/perl

#Computes the LEUS probabilities of the syn and anti conf of GTP + error estimates#### 

if ($ARGV[0] eq "") {
    print "Usage of this script : angle  vs bias file\n";
    exit 1; 
}

###Configuratonal Unbias subroutine####

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

sub Unbias_conf {
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
		my $value_exp =0.0;
		if ($values[$count] == 0){
			
			$value_exp     = 0;	
		}
		else {
			$value_exp     = exp ($values[$count]/($kbT));
		}
		push (@exp_avrgs,$bias_exp );
		push (@values_exp_avrg ,$value_exp );
		$exp_aver         += $bias_exp;
		$value_exp_aver   += $value_exp;
	}
	$exp_aver = $exp_aver/	$size_x;
	$value_exp_aver =$value_exp_aver/$size_x;
	$reweighted_average = $value_exp_aver/$exp_aver;
	return ($reweighted_average, $value_exp_aver, $exp_aver, \@exp_avrgs,\@values_exp_avrg);
}





###MAIN#####

(@anti) =();
(@syn)  =();
(@biases) = ();
$T=298;
$kb = 0.008314511212;
$kbT=$kb*$T; 

# loop trough the value vs bias file collect bias for anti and syn states

open (FILE_1, "$ARGV[0]");
while ($line=<FILE_1>) {
	if ($line=~/(\S+)\s+(\S+)/) {	 
		$angle =$1;
		$angle =~s/\s+//g;
		$bias = $2;
		$bias =~s/\s+//g;
		push(@biases, $bias);
		if ( ($angle >=140 && $angle <= 340) && ($bias != 0) ) {
			push(@anti, $bias);
			push(@syn, "0");
		}
		if ( ($angle > 340 || $angle < 140) && ($bias != 0) ) {
			push(@syn, $bias);
			push(@anti, "0");		
		}
					
	}
}
close FILE_1;

#Get sizes of anti, syn and total arrays (for adding zeroes)

## ANTI calculation##

#Unbias the anti quantity and get arrays of exp(bias) and exp(bias)_anti
($average_unbiased,$value_exp_bias_avrg,$exp_bias_avrg,$a,$b)= &Unbias_conf(\@anti,\@biases,$T);
@exp_bias_array= @$a;
@value_exp_bias_array = @$b; # exp(bias)_anti array

$P_anti = $average_unbiased; 

#Dirty way to get error estimates using tcf (gromos++ program)

open (OUT_2, ">exp_bias.dat");       #exp(bias) timeseries  file
open (OUT_3, ">anti_exp_bias.dat");  #exp(bias)_anti timeseries  file
print OUT_2 "\# Timeseries of exp(bias/kbT)\n";

foreach (@exp_bias_array) { 
	print OUT_2 "$_ \n";
}

print OUT_3 "\# Timeseries of exp(bias/kbT)_anti\n";
foreach (@value_exp_bias_array) {
	print OUT_3 "$_ \n";
}


close OUT_2;
close OUT_3;

system ("tcf \@files anti_exp_bias.dat \@distribution 1 > error_anti_exp_bias.dat");
system ("tcf \@files exp_bias.dat \@distribution 1 > error_exp_bias.dat");

#Get the errors from tcf output
open (FILE_1, "error_anti_exp_bias.dat");  #exp(bias)_anti error  file
open (FILE_2, "error_exp_bias.dat");       #exp(bias) error  file

$bool_line_1 = 0;
$bool_line_2 = 0;
while (($line_1=<FILE_1>) && ($line_2=<FILE_2>)) {

	if (($line_1=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_1 == 2)) {
		#print "$1\n";
                $error_anti_exp_bias =$1;
		#print "$error_anti_exp_bias\n";
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


$error_anti = (abs($value_exp_bias_avrg/$exp_bias_avrg))*sqrt(($error_anti_exp_bias/$value_exp_bias_avrg)**2 + ($error_exp_bias/$exp_bias_avrg)**2);

## END ANTI calculation##


##SYN CALCULATION####

#Unbias the syn quantity and get arrays of exp(bias) and exp(bias)_syn

($average_unbiased,$value_exp_bias_avrg,$exp_bias_avrg,$a,$b)= &Unbias_conf(\@syn,\@biases,$T);
@exp_bias_array= @$a;
@value_exp_bias_array = @$b; # exp(bias)_syn array

$P_syn = $average_unbiased; 

#Dirty way to get error estimates using tcf (gromos program)

open (OUT_3, ">syn_exp_bias.dat"); #Syn*exp(bias) timeseries  file
print OUT_3 "\# Timeseries of syn*exp(bias/kbT)\n";
foreach (@value_exp_bias_array) {
	print OUT_3 "$_ \n";
}  


close OUT_3;
system ("tcf \@files syn_exp_bias.dat \@distribution 1 > error_syn_exp_bias.dat");

#Get the errors from tcf output for syn
open (FILE_1, "error_syn_exp_bias.dat");  #exp(bias)_syn error  file

$bool_line_1 = 0;
while ($line_1=<FILE_1>) {

	if (($line_1=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_1 == 2)) {
                $error_syn_exp_bias =$1;
		$bool_line_1 =0;
        }
	if ( $line_1=~/^STATISTICS/) {$bool_line_1++;}	
	if ( $line_1=~/^#/) {$bool_line_1++;}		
}


$error_syn = (abs($value_exp_bias_avrg/$exp_bias_avrg))*sqrt(($error_syn_exp_bias/$value_exp_bias_avrg)**2 + ($error_exp_bias/$exp_bias_avrg)**2);

## End SYN CALCULATION###


##Get Anti to Syn G and total error
$G_anti_syn = -$kbT*log($P_syn/$P_anti);
# The log cancels out with the absolute error !!!!
$total_error = $kbT*sqrt( ($error_syn/$P_syn)**2 + ($error_anti/$P_anti)**2 );


printf   "%10s   %10s   %10s   %10s   %10s   %10s\n","# P Anti unbias", "unbias error", "P Syn unbias", "unbias error", "G anti-syn", "G error";
printf   "%10.2f    %10.2f     %10.2f     %10.2f    %10.2f      %10.2f\n",$P_anti, $error_anti, $P_syn, $error_syn,$G_anti_syn,$total_error;




