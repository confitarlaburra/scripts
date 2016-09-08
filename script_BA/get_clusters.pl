#!/usr/bin/perl

if ($ARGV[0] eq "")  {
    print "Usage of this script /path/to/cluster_structures.dat/";
    exit 1; 
}

open (IN, "$ARGV[0]");
@centers=();
$bool=0;
while ($line=<IN>){
    if ($line=~/^END/) {
	$bool=0;
    }
    if ($line=~/^CLUSTER\s+/){
	$bool=1;
    }
    if ($bool  ==1) {
	#print $line;
	if ($line =~/\s+\S+\s+(\S+\d+)/) {
	    print "$1\n";
	    $center=$1;
	    $center =~s/\s+//g;
	    push(@centers, $center);
	}
    } 

}

close IN;

for (my $i=1; $i < @centers; $i++) {
   print "printing frame $centers[$i]\n";
   
}

 #$catdcd = `pore_ax_rad \@f  $name.axial.arg > $name.out`;
#if ($out !=0) {
#	print "pore_axial failed";
#}
