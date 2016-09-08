#!/usr/bin/perl

### hist subroutine####
# Calculates the unbias probability of each bin
# Input: 
# @{$_[0]} = array of values t
# $_[1] = bin number
# $_[2] = min of values
# $_[3] = max of values
# How to use it :
# ($a)= &bins(\@values,$bin_number,$min,$max);
# @bins= @$a;
####################################################################################################

sub Hist 
{
 my (@values) = @{$_[0]};
 my $bin_number = $_[1];
 my $min = $_[2];
 my $max = $_[3];
 my $size_x = @values;
 @bins =();
 for ($count = 0; $count <= $size_x; $count++)
 {
    $step =  int(( ($values[$count]-$min)/(($max-$min)/($bin_number)) ));
    $bins[$step] ++;
 }

return ( \@bins);
}


 sub max 
{
 my($max)=shift(@_);
 foreach $temp (@_) 
 {
    $max = $temp if $temp > $max;
 }
  return($max);
}


 sub min 
{
 my($min)=shift(@_);
 foreach $temp (@_) 
 {
    $min = $temp if $temp < $min;
 }
  return($min);
}


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



##MAIN##

$nwaters=7;
@P1;
@time;			
$count_waters=1;
@values = ();
$bin_number = 100;
$min = 0;
$max =0;


#Read Files
while ($count_waters <= $nwaters) {
	$file = "$count_waters.out";
	open ($count_waters, "$file");
	while ($line=<$count_waters>)  {
		if (($line=~/(\d+\S+)\s+(\S+)/)) {
			#print "$2\n"; 			
			push(@values, $2); 
		}	
       }
      $count_waters++;
      close $count_waters;	
}

$max = max @values;
$min = min @values;
print "#min= $min max =$max\n"; 
$bin_number= 25;
$bin_size= ($max-$min)/$bin_number;
($a)= &Hist(\@values,$bin_number,$min,$max);
@bins= @$a;

$size =@bins;
@x=();

#Get array of real bins to normalize
for($i=0;$i<$size;$i++){
    $step=($bin_size*$i) - abs($min);
    push (@x,$step);
}

#Get Integral to normalize
($integral) = &TrapInt(\@x,\@bins);
print  "# Value of integral is = $integral\n"; 

for($i=0;$i<$size;$i++){
    $bins[$i]/=abs($integral);	
    printf   "%14.8f %14.8f\n", $x[$i],$bins[$i];
}










