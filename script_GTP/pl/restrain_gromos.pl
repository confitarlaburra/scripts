#!/usr/bin/perl

if (($ARGV[0] eq "") && ($ARGV[1] eq "")) {
    print "Usage of this script : cnffile restrain resname";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
open (OUT,  ">test.cnf");
$i =0;
print OUT "TITLE\nsolute atoms to be positionally restrained\nEND\nPOSRESSPEC\n"
while ($line=<FILE_1>) {
	if ($line=~/$ARGV[1]/) {
		print OUT $line;				
	}
}
print OUT "END";
close FILE_1;
close OUT;
