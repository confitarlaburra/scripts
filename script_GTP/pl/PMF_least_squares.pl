#!/usr/bin/perl

###LeastSqr####

# Input: 
# @{$_[0]} = array of biases to which the constat is to be added
# @{$_[1]} = reference array of biases;
# Returns array of fitted (bias)
# Typical usage :
	# ($a)= &LeastSqr(\@US1_array,\@US2_array); #US1_array bias array to be shifted with respect to @US2_array
	#  @biases_shifted= @$a; # shifetd bias array

####################################################################################################

sub LeastSqr {
	my (@biases_1) = @{$_[0]}; # array to which the constat is to be added
        my (@biases_2) = @{$_[1]}; # reference array
	my $kbT=$kb*$T; 
	my $size_x = @biases_1;
	my $size_y = @biases_2;	
	if ($size_x != $size_y) { print "values and bias must be the same size\n"; exit 1;}
	$US_constant = 0.0;		
	for ($count = 0; $count < $size_x; $count++) {
		$US_constat += -($biases_1[$count] - $biases_2[$count]);  	
	}
	$US_constat /= $size_x;
	for ($count = 0; $count < $size_x; $count++) {
		$biases_1[$count]+= $US_constat; 	
	}
	return (\@biases_1);
}


###Min####
# subroutine that takes an array and finds the min element
sub min {
	my($min)=shift(@_);
        foreach $temp (@_) {
        	$min = $temp if $temp < $min;
        }
        return($min);
}
### ShiftZero####
# subroutine that takes an array and shifts al its elements by element - min
# use: ($a)= &ShiftZero(\@array); # array to be shifted
#            @array= @$a; # shifted array
sub ShiftZero  {
	my (@array) = @{$_[0]};
	my ($min) = min @array;
	my $size = @array;
	for ($count = 0; $count < $size; $count++) {
		$array[$count] -= $min ;  	
	}
	return (\@array);
}

###Main#######

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ) {
    print "Usage of this script : \"coordinate vs bias 1 (bias to be shifted)\"  \"coordinate vs bias 2\"\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]"); #pmf file 1 output from unbias_bin.pl script (angle vs  prob pmf) to be shifted
open (FILE_2, "$ARGV[1]"); #pmf file 2 output from unbias_bin.pl script (angle vsd prob pmf) 

@pmf1_array=();
@pmf2_array=();
@coordinates=();


##Read input file to fill bias arrays.

while (($line_1=<FILE_1>) && ($line_2=<FILE_2>)) {	
	
	if ($line_1=~/^\s+(\S+)\s+\S+\s+(\S+)/) {
		$coordinate= $1;
		push(@coordinates, $coordinate);
                $pmf_1 =$2;
		#print "$1 $2\n";
		push(@pmf1_array, $pmf_1);

        }
	
	if ($line_2=~/^\s+\S+\s+\S+\s+(\S+)/) {
                $pmf_2 =$1;
		push(@pmf2_array, $pmf_2);
        }

}


close FILE_1;
close FILE_2;


#Least squares minimization and print the minimized potential for further use
($a)= &LeastSqr(\@pmf1_array,\@pmf2_array); #US1_array bias array to be shifted
@pmfs_shifted= @$a; # shifetd bias array
$size = @pmfs_shifted;
#open (OUT, ">shifted_bias.dat");
#for ($count = 0; $count < $size; $count++) {
#	print OUT "$coordinates[$count] $pmfs_shifted[$count]\n";
#}
#close OUT;


#Shift to zero

#($a)= &ShiftZero(\@pmfs_shifted); #US1_array bias array to be shifted
#@pmfs_shifted= @$a; # inverted shifted bias array

#($a)= &ShiftZero(\@pmf2_array); #US1_array bias array to be shifted
#@pmf2_array= @$a; # inverted bias array


#Print  coordinates bias and minimized biass
printf "%10s   %5s   %10s\n", "#Coordinates","Ref bias","lqsr Bias";
for ($count = 0; $count < $size; $count++) {
	printf "%10.3f %10.2f %10.2f\n",  $coordinates[$count],  $pmf2_array[$count], $pmfs_shifted[$count];
}	


