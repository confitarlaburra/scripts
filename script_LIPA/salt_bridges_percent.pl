#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : script.pl salbridge_bins_file\n";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
$i =0;
$j=0;
while ($line=<FILE_1>) {
	if ( $line =~/\S+\s(\S+)/ ) {
                       $j+=$1;
			$i++;
			print "$1 $i $j\n";
			
	}
}

$average = ($j/$i)*100;
print "$average\n";
close FILE_1;
