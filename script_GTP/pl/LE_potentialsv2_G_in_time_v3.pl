#!/usr/bin/perl

#####################################################################################################
#Script that calculates the total biasing potential perl collective coordinate window over an LE run
#####################################################################################################
if (($ARGV[0] eq "") || ($ARGV[1] eq "" ))  {
    print "Usage of this script : scrip.pl LE_out_file printing_frequency (in time steps)\n";
    exit 1; 
}
#####################################################
# &binwidth ($VARTYPE, $GRIDMAX, $GRIDMIN, $NGRID);
#####################################################
## Subroutine to get the bin width ##
# $_[0] == variable type (0 = distances, 1 = angle).
# $_[1] == $GRIDMAX.
# $_[2] == $GRIDMIN.
# $_[3] == $NGRID.
#  Returns the bin width

sub binwidth {
	if ($_[0] == 0) {
		$width = (($_[1] - $_[2]) / $_[3])
	} else {
		$width = 360/$_[3];
  	}
	return ($width);
}
#####################################################################################################
# &GeneralPotentials($number_sub_bins,$width,$CLES);
#####################################################################################################
## Subroutine to get added potential general form ##
# General form of the potetial added of the form of a polynomial with continuous 1st derivative.
# $_[0] == $number_sub_bins (half the number of total points computed for the added potentials).
# $_[1] == $witdh, bin width.
# $_[2] == $CLES force constant.
# Returns two arrays with the unbinned distances (centered around 0) and the corresponding biases.  

sub GeneralPotentials {
	@distances=();
	@bias=();
	for ($count = 1; $count <= ($_[0]*2 +1); $count++) {
 		$distances[$count] = 0.0;
		$bias[$count]=0.0;
	}
        my $i = (-$_[1]);
	for ($count = 1; $count <= ($_[0]*2 +1); $count++) {
		 $distances[$count] = $i;
		 $i = $i + ($_[1]/$_[0]);
		 $bias[$count] = $_[2] * (1-((3*(abs($distances[$count])**2))/($_[1]**2))+((2*(abs($distances[$count])**3))/($_[1]**3))); 		
	}
	return (\@distances,\@bias);
}
#####################################################################################################################################################
## &PrintPotential($NGRID,$width,\@distances,\@bias,\@gridpoints,$number_sub_bins);
#####################################################################################################################################################
## Subroutine that transforms the binned output  into unbinned form, using the general potential distances and biases arrays (from GeneralPotentials)
# and the gridpoints\visited times (@gridpoints) array from the input (LE out file).
#It basically centers the general potential form ,according to the respective bin, and multiplies its values by the visited times.
#At the end ,it also, checks the overlapping distances and sum these values.
# $_[0] $NGRID number of grids
# $_[1] $width bin width
# $_[2] @distances unbinned distances array
# $_[3] @bias bias potential array
# $_[4] @gridpoints array with gridpoints (index) and visited times (values of each element of gridpoints)
# $_[5] $number_sub_bins (half the number of total points computed for the added potentials)
# Returns two arrays with the bias (cumulative) and the distances.
   
sub PrintPotential {
	 (@total_biases)=();
	 (@real_distances)=();
	 (@rounded)=();
	 (@sum)=();
	 (@distances) = @{$_[2]};
         (@bias) = @{$_[3]};
	 (@gridpoints) = @{$_[4]};
	 for ($counter = 1; $counter <= $_[0]; $counter++) {
 		$ref = $_[1]*$counter;
        	for ($count =1; $count<=(($_[5])*2 +1); $count++) {
                	$real_distance= $ref + $distances[$count]- $_[1];
			if ($real_distance>360) { $real_distance= $real_distance -360;}
			if ($real_distance < 0) { $real_distance= $real_distance + 360;}
			$real_distance = sprintf "%.2f", $real_distance;  
			$total_bias=$bias[$count]*$gridpoints[$counter]; 
			push(@total_biases,$total_bias );
                	push(@real_distances,$real_distance );		
		}	
	}
	$length=@real_distances;
	for ($counter = 0; $counter <= $_[0]*$_[1]; $counter+= ($_[1]/$_[5]) ) {
		$sum=0;
		$t=0;
		$rounded = sprintf "%.2f", $counter;
		for ($j = 0; $j <= $length; $j++ ) {
			if ($rounded == $real_distances[$j]) {
				$sum= $sum + $total_biases[$j];
			}
		}
		push(@rounded,$rounded);
		push(@sum,$sum);
		
	}
	return (\@rounded,\@sum);
}
####################################
		## Main ## 
####################################
#initialization of variables
$printing_frequency = $ARGV[1];
@gridpoints =();
$NCONLE = 0.0;
$NUMUMBRELLAS = 0.0;
$NLEPID = 0.0;
$NDIM = 0.0;
$CLES = 0.0;
$VARTYPE = 0.0;
$NTLEFU = 0.0;
$WLES = 0.0;
$RLES = 0.0;
$NGRID = 0.0;
$GRIDMIN = 0.0;
$GRIDMAX = 0.0;
$NCONLE = 0.0;
open (FILE_1, "$ARGV[0]");
$i =0;
$t=-1;
$number_sub_bins=100;
$time_step = 0.0;
$time = 0.0;
$time_counter = 0.0;
#$kb = 1.3806488E−23;
$kb = 0.008314511212;
$T = 298;
$kbT=$kb*$T; 
#First pass to get initial parameters from LE output file#
while ($line=<FILE_1>) {          
		if ($i>=1) {$i++;}
                last if ($i > 8);
		if (($i==3) && ($line=~/(\S+)/)) {
			$NUMUMBRELLAS = $1;
			$NUMUMBRELLAS =~s/\s+//g;		
	        }
		if (($i==5) && ($line=~/\s+(\S+)\s+(\S+)\s+(\S+)/)) {
			$NLEPID  = $1;
			$NLEPID  =~s/\s+//g;	
			$NDIM  = $2;
			$NDIM  =~s/\s+//g;
                        $CLES = $3;
			$CLES  =~s/\s+//g;
	        }
		if (($i==7) && ($line=~/\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)) {
			$VARTYPE  = $1;
			$VARTYPE =~s/\s+//g;	
			$NTLEFU  = $2;
			$NTLEFU  =~s/\s+//g;
                        $WLES = $3;
			$WLES  =~s/\s+//g;
			$RLES  = $4;
			$RLES =~s/\s+//g;	
			$NGRID  = $5;
			$NGRID  =~s/\s+//g;
                        $GRIDMIN = $6;
			$GRIDMIN =~s/\s+//g;
                        $GRIDMAX = $7;
			$GRIDMAX =~s/\s+//g;
	        }		
        if ($line=~/^LEUSBIAS/) {$i =1;}
}

for ($count = 1; $count <= $NGRID; $count++) {
 	$gridpoints[$count] = 0.0;
}
close FILE_1;

#Get bin width
$width = &binwidth ($VARTYPE, $GRIDMAX, $GRIDMIN, $NGRID);
$points =$number_sub_bins*2; 
print "Bin size = $width\n";
print "CLES = $CLES\n";
print "Points per biasing potential= $points\n";
 
#Get the general unbinned form of the biasing potential
($a,$b)= &GeneralPotentials($number_sub_bins,$width,$CLES);
@distances = @$a;
@bias = @$b;
# Second pass to get the gridpoints and print final values
open (FILE_1, "$ARGV[0]");
open (OUT1, "> bin_cout_ts.dat");
open (OUT3, "> Delta_G_ts.dat");
while ($line=<FILE_1>) { 
        if (($t==0) && ($line=~/\s+(\S+)/)) {		
		$NCONLE = $1;
		$NCONLE =~s/\s+//g;
		$t++;
		#$file_counter++;
				
	}
	if (($t>=2) && ($line=~/\s+(\S+)\s+(\S+)/)) {
		$gridnumber=$2;
      		$gridnumber =~s/\s+//g;
                $number_of_visits=$1;
                $number_of_visits =~s/\s+//g;
		$gridpoints[$gridnumber]=$number_of_visits;
		$t++;
	}
	if ($t >= ($NCONLE +2)) { $t = -1;}
	if ($line=~/NCONLE/) {$t =0;}
	if ($line=~/NVISLE/) {$t ++;}
	if ($line=~/TIMESTEP/) {$h =1;}
	if (($h==1) && ($line=~/\s+(\S+)\s+(\S+)/)) {
		$time_step = $1;
		$time_step =~s/\s+//g; 
		$h=0;
		$size = 0;
                $time =$2;
                $time =~s/\s+//g;
                $time = sprintf "%.2f", $time;
		$time_counter++; 
		foreach $grid (@gridpoints) {
			if ($grid != 0) {$size++;}
		}
		if ($time_counter >= 2){print  OUT1 "$time $size\n";} # counting the visited bins
	} 
	if (($time_step%$printing_frequency == 0.0) && ($h == 1)) {
		open (OUT,">$ARGV[0].$time.dat");
		($a,$b)= &PrintPotential($NGRID,$width,\@distances,\@bias,\@gridpoints,$number_sub_bins);
		@rounded = @$a;
		@sum = @$b;
		$length2=@rounded;
		$Counter_Syn=  0.0;
		$Counter_Anti = 0.0;
		$G_Syn=0.0;
		$G_Anti=0.0;
		print "$time\n";
		for ($j = 1; $j <= $length2; $j++ ) {
			print OUT "$rounded[$j] $sum[$j]\n";
			if ( ($rounded[$j] >=140 && $rounded[$j] <= 340) && ($sum[$j] != 0) ) {
				$G_Anti = $G_Anti + exp($sum[$j]/($kbT));
				$Counter_Anti++;
			}
			if ( ($rounded[$j] > 340 || $rounded[$j] < 140) && ($sum[$j] != 0) ) {
				$G_Syn = $G_Syn + exp($sum[$j]/($kbT));
				$Counter_Syn++;
			}
			
		}
		if ($Counter_Anti >= 1) {  $G_Anti = -$kbT*log($G_Anti/$Counter_Anti); } else {$G_Anti = 0.0;}
		if ($Counter_Syn >= 1 ) {  $G_Syn = -$kbT*log($G_Syn/$Counter_Syn);    } else {$G_Syn = 0.0;}
		$Delta_G = $G_Syn - $G_Anti;	
		$Delta_G = sprintf "%.2f", $Delta_G ;
		$G_Anti  = sprintf "%.2f", $G_Anti ;
		$G_Syn   = sprintf "%.2f", $G_Syn ;
		if ($time_counter >= 1) {print OUT3 "$time $G_Anti $G_Syn $Delta_G\n";}
		close OUT;
	} 
}

#Print the last bias potential#
($a,$b)= &PrintPotential($NGRID,$width,\@distances,\@bias,\@gridpoints,$number_sub_bins);
open (OUT2,">$ARGV[0].$time.dat");
@rounded = @$a;
@sum = @$b;
$length2=@rounded;
print "$time\n";
#print "@gridpoints\n";
$Counter_Syn=  0.0;
$Counter_Anti = 0.0;
$G_Syn=0.0;
$G_Anti=0.0;
for ($j = 1; $j <= $length2; $j++ ) {
	print OUT2"$rounded[$j] $sum[$j]\n";
	if ( ($rounded[$j] >=140 && $rounded[$j] <= 340) && ($sum[$j] != 0) ) {
		$G_Anti = $G_Anti + exp($sum[$j]/($kbT));
		$Counter_Anti++;
	}
	if ( ($rounded[$j] > 340 || $rounded[$j] < 140) && ($sum[$j] != 0) ) {
		$G_Syn = $G_Syn + exp($sum[$j]/($kbT));
		$Counter_Syn++;
		#print "$Counter_Syn $rounded[$j] $G_Syn\n";
	}
}

if ($Counter_Anti >= 1) {  $G_Anti = -$kbT*log($G_Anti/$Counter_Anti); } else {$G_Anti = 0.0;}
if ($Counter_Syn >= 1 ) {  $G_Syn = -$kbT*log($G_Syn/$Counter_Syn);    } else {$G_Syn = 0.0;}

$Delta_G = $G_Syn - $G_Anti;	
$Delta_G = sprintf "%.2f", $Delta_G ;
$G_Anti  = sprintf "%.2f", $G_Anti ;
$G_Syn   = sprintf "%.2f", $G_Syn ;

print OUT3 "$time $G_Anti $G_Syn $Delta_G\n";

close FILE_1;
close OUT1;
close OUT2;
close OUT3;	
