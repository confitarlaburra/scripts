#!/usr/bin/perl

#Script that prints energy componets as function of load. JAG 3/07/14

## Function that print energy components normalized by center(1), full (load) of mouth(2)
## prints energy components as function of loading
# USAGE:
# PrintComponents(data_file,min ,max ,max_load);
sub PrintComponents{}


#### Main#####
if (($ARGV[0] eq "") ||  ($ARGV[1] eq "") ||  ($ARGV[2] eq "")) {
    print "Usage of this script : min max max_oad\n";
    exit 1; 
}

$min=$ARGV[0];
$max=$ARGV[1];
$maxLoad=$ARGV[2];

@dats = <*.dat>;
#load every.dat file in directory
foreach $dat (@dats) {
    PrintComponents($dat,$min,$max,$maxLoad);
    print "$dat.plot printed in WD!!! \n";
} 

### END MAIN ###

#Function implementation ###

sub PrintComponents {
    open (FILE, "$_[0]");
    $string=$_[0];
    $string=~s/\.dat//g;
    $min = $_[1];
    $max = $_[2];
    $maxLoad = $_[3];
    $outname = "$_[0].plot";
    @energyLoads   =  ();
    %Energy_hash = (
	'Loaded' => 1, 
	'Notloaded' => 2 , 
	'Pore' => 3 , 
	'Self' => 4 , 
	'Solvent' => 5, 
	'Total' => 6 
	);
    open (OUT, ">$outname");
    while ($line=<FILE>) {
	if ($line=~/^#Load\s+(\d+)/) {
	    $load =$1;
	    $load =~s/\s+//g;
	    #print "$load\n";
    }
	if ($line =~/\s+(\S+)\s+(\S+\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
	    $comp=$1;
	    $comp =~s/\s+//g;
	    $element =$Energy_hash{$comp};
	    if ($string eq "full") {
		$two=$2/$load;
		$three=$3/$load;
		$four=$4/$load;
		$five=$5/$load;
	    }
	    if ($string eq "mouth") {
		$two=$2/2;
		$three=$3/2;
		$four=$4/2;
		$five=$5/2;
	    }
	    if ($string eq "center") {
		$two=$2;
		$three=$3;
		$four=$4;
		$five=$5;
	    }
	    if ($2 eq "-nan") {
		$energyLoads[$load][$element][0][0] = 0;
	    }
	    else { 
		$energyLoads[$load][$element][0][0] = $two;
	    }
	    if ($3 eq "-nan") {
		$energyLoads[$load][$element][0][1] = 0;
	    }
	    else {
		$energyLoads[$load][$element][0][1] = $three;
	    }
	    if ($4 eq "-nan") {
		$energyLoads[$load][$element][1][0] = 0;
	    }
	    else {
		$energyLoads[$load][$element][1][0] = $four;
	    }
	    if ($5 eq "-nan") {
		$energyLoads[$load][$element][1][1] = 0;
	    }
	    else {
		$energyLoads[$load][$element][1][1] = $five;
	    }
	}
    }

    @comps = keys %Energy_hash;
    print OUT "#Load%    ";
    for $comp (@comps) {
	$comp_tmp ="$comp LJ";
	printf OUT ("%10s ",$comp_tmp);
	printf OUT ("%10s ","error");
	$comp_tmp ="$comp RF";
	printf OUT ("%10s ",$comp_tmp);
	printf OUT ("%10s ","error");
    }
    print OUT "\n";
    for ( $i=$min; $i <= $max; $i++) {
	$loadPercent=($i/$maxLoad)*100;
	printf OUT ("%6.2f  ",$loadPercent);
	@comps = keys %Energy_hash;
	for $comp (@comps) {
	    for ( $j=0; $j <= 1; $j++) {
		printf OUT  ("%10.2f ",$energyLoads[$i][$Energy_hash{$comp}][$j][0]);
		printf OUT ("%10.2f ",$energyLoads[$i][$Energy_hash{$comp}][$j][1]);
	    }
	}
	print OUT "\n"
    }
}
