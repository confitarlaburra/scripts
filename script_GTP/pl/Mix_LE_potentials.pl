#!/usr/bin/perl

## subroutine tha calculates the weighted sum of biases potentials##
# bias one lambda = 0.0
# bias two lambda = 1.0
sub GeneralPotentials {
	$lambda=$_[0]; 
	(@bias_1) = @{$_[1]};
        (@bias_2) = @{$_[2]};
	(@newbias)=();
	$size =@bias_1;
	for ($count = 0; $count  < $size; $count++) {
 		$new = (1-$lambda)*$bias_1[$count] + $lambda*$bias_2[$count];
		#round to the nearest integer
		$new = int($new +0.5);
		$newbias[$count]= $new;
 	}
	return (\@newbias);
}
##################################################################################################
## main##
##################################################################################################
if (($ARGV[0] eq "") || ($ARGV[1] eq "")  || ($ARGV[2] eq "") || ($ARGV[3] eq ""))  {
    print "Usage of this script : scrip.pl cnf_bias_1(lambda 0) cnf_bias_2(lambda 1) cnf_md (actual lambda point )  lambda_point\n";
    exit 1; 
}


open (FILE_1, "$ARGV[0]"); # ARGV[0] and FILE_1 = first  cnf file
open (FILE_2, "$ARGV[1]"); # ARGV[1] and FILE_2 = second cnf file
open (FILE_3, "$ARGV[2]"); # ARGV[2] and FILE_3 = init CNF for simulation
$name = "$ARGV[2].LE.cnf";
open (OUT, "> $name");     # OUT init CNF for simulation + LE potential

$counter  =  0.0;
$lambda   =  $ARGV[3];


#Read cnf 1 and get 1st LE potential
while ($line=<FILE_1>) {	
	if ($line=~/NVISLE/) { $counter = 1;}
	if ($counter == 1 && $line=~/\s+(\d+)\s+(\d+)/) {
		$visits_1 = $1;
		$bin = $2;
		#print "$visits_1\n";
		push(@visits_1_array,$visits_1);
		push(@bins,$bin); 
	}
	if ($line=~/END/) { $counter = 0.0;}
}

#Read cnf 2 and get 2nd LE potential
while ($line=<FILE_2>) {	
	if ($line=~/NVISLE/) { $counter = 1;}
	if ($counter== 1 && $line=~/\s+(\d+)\s+(\d+)/) {
		$visits_2 = $1;
		$bin = $2;
		#print "$visits_2\n";
		push(@visits_2_array,$visits_2);
	}
	if ($line=~/END/) { $counter = 0.0;}
}



while ($line=<FILE_3>) {
	print OUT "$line";	
}
close FILE_1;
#get LE potentials
open (FILE_1, "$ARGV[0]");
while ($line=<FILE_1>) {	
	if ($line=~/LEUSBIAS/) { $counter = 1; }
	if ($counter == 1) {print OUT $line;}
	if ($line=~/NVISLE /) { $counter = 0.0;}
}

##Compute New weighted bias potential##
($a)= &GeneralPotentials($lambda,\@visits_1_array,\@visits_2_array);
@newbias = @$a;

$size = @newbias;
for ($count = 0; $count < $size; $count++) {
	 printf OUT  "%10.d %9.d\n", $newbias[$count], $bins[$count];
}
print OUT "END";

close FILE_1;
close FILE_2;
close OUT;
