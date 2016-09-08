#!/usr/bin/perl

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ) {
    print "Usage of this script  z.file force.file";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
open (FILE_2, "$ARGV[1]");
open (OUT, ">force_vs_z.dat");

while ( ($line_1=<FILE_1>) && ($line_2=<FILE_2>) ) {

	if ($line_1=~/(\d+)\s(\S+)/) {
		$frame = $1;
		$frame =~s/\s+//g;
		$z = $2;
		$z =~s/\s+//g;		
	}

	if ($line_2=~/(\d+)\s(\S+)/) {
		$frame = $1;
		$frame =~s/\s+//g;
		$force= $2;
		$force =~s/\s+//g;		
	}
	print OUT "$z $force \n";
}
	
		
close FILE_1;
close FILE_2;
close OUT;
