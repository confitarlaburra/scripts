#!/usr/bin/perl

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ) {
    print "Usage of this script : dihed.file ener.file\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]"); #dihed file
open (FILE_2, "$ARGV[1]"); #energy file


while (($line_1=<FILE_1>) && ($line_2=<FILE_2>)) {
	
	if ($line_1=~/\d+\S+\s+(\S+)/) {
		$angle = $1;
	}
	if ($line_2=~/\s+\d+\s+(\S+)/) {
		#print "$line_2";
		$energy =$1;
	}
	if ($line_2=~/\s+\d+\S+\s+(\S+)/) {
		#print "$line_2";	 
		$energy =$1;
	}
	print "$angle $energy\n";	
}


close FILE_1;
