#!/usr/bin/perl

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ) {
    print "Usage of this script  script.pl average.file sd.file";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
open (FILE_2, "$ARGV[1]");
open (OUT, ">average_ms.dat");
$i = 0;
while ( ($line_1=<FILE_1>) && ($line_2=<FILE_2>) ) {

	if ($line_1=~/(\d+)\s(\S+)/) {
		$frame = $1;
		$frame =~s/\s+//g;
		$average = $2;
        	$average =~s/\s+//g;
	}
	if ($i == 0) {  
		if ($line_2=~/(\d+)\s(\S+)/) {
			$sd = $2;
        		$sd =~s/\s+//g;
		}
	} else { $sd = 0;}
	
	if ($i > -1) {
		$i = 0;		
	}
	#$i++;
	#print $sd;	
	print OUT "$frame $average $sd \n";

}

close FILE_1;
close FILE_2;
close OUT;
