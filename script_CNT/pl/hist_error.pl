### hist subroutine####
# Calculates the unbias probability of each bin
# Input: 
# @{$_[0]} = array of values t
# $_[1] = bin number
# $_[2] = min of values
# $_[3] = max of values
# How to use it :
# ($a)= &Unbias_bins(\@values,$bin_number,$min,$max);
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
 for ($count = 0; $count <= $bin_number; $count++) 
 {
	$bins[$count] /= $size_x;
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



### MAIN ###
if ($ARGV[0] eq "") {
    print "Usage of this script : values_file\n";
    exit 1; 
}

### Fill every time####
(@values) = ();
$bin_number = 13;
$min = 0;
$max =12;

### MAIN #####

open (FILE, "$ARGV[0]"); #timseries of values

while ($line=<FILE>) 
{
 if ($line=~/\d+\S+\s+(\S+)/) 
 {	 
    $value =$1;
    $value =~s/\s+//g;
    #print "$value\n";
    push(@values, $value);		
 } 
   
}
close FILE;

$max = max @values;
$bin_number= $max - $min ;
($a)= &Hist(\@values,$bin_number,$min,$max);
@bins= @$a;
   
### Make array if each bin with 1 (if true) or zero if wrong####

for ($count = 0; $count <= $bin_number; $count++)
{
  push (@indexes, $count); #array of indexes of bins
  (@$count)=();	
}
foreach $value (@values)
{
   $step =  int(( ($value-$min)/(($max-$min)/($bin_number)) ));
   push (@{$step},1);
   @array = grep { $_ != $step } @array; #delete step from array (temporal)
   foreach $index (@indexes) 
   {
     push (@{$index},0);	
   }
   push (@array, $step)
}

#output files for TCF, run TCF and collect error estimates
(@errors)=();
for ($count = 0; $count <= $bin_number; $count++)
{	
    open (OUT, ">$count.bin.dat");
    print OUT "# $count bin binary ts\n";
    foreach $value (@{$count})
    {
       print OUT "$value\n";
    }
    close OUT;
    system ("tcf \@files $count.bin.dat \@distribution 1 > $count.bin_error.dat");
    open (FILE, "$count.bin_error.dat"); # error  file
    $bool_line_1 = 0;
    while ($line_1=<FILE>) {
      if (($line_1=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_1 == 2)) {
           $error =$1;
           $bool_line_1 =0;
	   push (@errors,$error);
        }
	if ( $line_1=~/^STATISTICS/) {$bool_line_1++;}	
	if ( $line_1=~/^#/) {$bool_line_1++;}
    }
    close FILE;		
}

#Delete intermediate files
for ($count = 0; $count <= $bin_number; $count++)
 {
   system ("rm $count.bin_error.dat $count.bin.dat");	
 }

#write final distribution with errors
printf   "%14s %14s %14s\n","# Bin", "Probability", "Error";


for ($count = 0; $count <= $bin_number; $count++) 
{	
	printf   "%14d %14.8f %14.8f\n","$count", "$bins[$count]", "$errors[$count]";
}
	

