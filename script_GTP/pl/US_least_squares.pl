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

###InvertArray####

# subroutine that takes an array and inverts is (*-1 each element)
# use: ($a)= &InvertArray(\@array); # array to be inverted
#            @array= @$a; # inverted array
sub InvertArray  {
	my (@array) = @{$_[0]};
	my $size = @array;
	for ($count = 0; $count < $size; $count++) {
		$array[$count] *= -1;  	
	}
	return (\@array);
}

# subroutine that gets the smallest element of a given array
# use: ($min) = min @array;

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
open (FILE_1, "$ARGV[0]"); #bias file 1 output from LE_bias_time.pl script (angle vs bias) to be shifted
open (FILE_2, "$ARGV[1]"); #bias file 2 output from LE_bias_time.pl script (angle vs bias) 

@US1_array=();
@US2_array=();
@coordinates=();


##Read input file to fill bias arrays.

while (($line_1=<FILE_1>) && ($line_2=<FILE_2>)) {	
	
	if ($line_1=~/^(\S+)\s+(\S+)/) {
		$coordinate= $1;
		push(@coordinates, $coordinate);
                $bias_1 =$2;
		push(@US1_array, $bias_1);

        }
	
	if ($line_2=~/^\S+\s+(\S+)/) {
                $bias_2 =$1;
		push(@US2_array, $bias_2);
        }

}


close FILE_1;
close FILE_2;


#Least squares minimization and print the minimized potential for further use
($a)= &LeastSqr(\@US1_array,\@US2_array); #US1_array bias array to be shifted
@biases_shifted= @$a; # shifetd bias array
$size = @biases_shifted;






open (OUT, ">shifted_bias.dat");
for ($count = 0; $count < $size; $count++) {
	print OUT "$coordinates[$count] $biases_shifted[$count]\n";
}
close OUT;



#Invert US potentials
#($a)= &InvertArray(\@biases_shifted); #US1_array bias array to be shifted
#@biases_shifted= @$a; # inverted shifted bias array

#($a)= &InvertArray(\@US2_array); #US1_array bias array to be shifted
#@US2_array= @$a; # inverted bias array




#Shift to zero

#($a)= &ShiftZero(\@biases_shifted); #US1_array bias array to be shifted
#@biases_shifted= @$a; # inverted shifted bias array

#($a)= &ShiftZero(\@US2_array); #US1_array bias array to be shifted
#@US2_array= @$a; # inverted bias array


#Print  coordinates bias and minimized biass
printf "%10s   %5s   %10s\n", "#Coordinates","Ref Bias","Minimized Bias";
for ($count = 0; $count < $size; $count++) {
	printf "%10.3f %10.2f %10.2f\n",  $coordinates[$count],  $US2_array[$count], $biases_shifted[$count];
}	


