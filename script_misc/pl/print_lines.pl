#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : namd.log.file";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
open (OUT,  ">self_5000.dat");
$i =0;
while ($line=<FILE_1>) {
	
	if ( $i >= 5000 ) {
		print OUT "$line";
	}
	$i++;
}

close FILE_1;
close OUT;
