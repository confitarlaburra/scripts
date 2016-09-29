#!/usr/bin/perl

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ) {
    print "Usage of this script : dihed.file ener.file\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]"); #dihed file
open (FILE_2, "$ARGV[1]"); #energy file


while (($line_1=<FILE_1>) && ($line_2=<FILE_2>)) {
	if ($line_2=~/^#/) {$bool_line_1 = 1;}
	if ( ($line_1=~/\d+\S+\s+(\S+)/) && ($bool_line_1 == 1)){
		$angle = $1;
	}
	

	if ($line_2=~/^#/) {$bool_line_2 = 1;}
	
	if (($line_2=~/^\s+(\S+)\s+\S+\s+(\S+)/) && ($bool_line_2 == 1)) {
		$time=$1;                 
		$energy_OSP =$2;
        }
	print "$angle $energy_OSP\n";	
}


close FILE_1;
close FILE_2;
