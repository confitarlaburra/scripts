#!/usr/bin/perl

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ) {
    print "Usage of this script  script.pl average.file sd.file";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
open (FILE_2, "$ARGV[1]");
open (OUT, ">average_ms.dat");

while ($line_1=<FILE_1>) {

	if ($line_1=~/(\d+)\s(\S+)/) {
		$frame = $1;
		$frame =~s/\s+//g;
		
		if ( $frame == 5000) {
			$average_5 = $2;
        		$average_5 =~s/\s+//g;	
		
		}


		if ( $frame == 10000) {
			$average_10 = $2;
        		$average_10 =~s/\s+//g;	
		
		}

		if ( $frame == 15000) {
			$average_15 = $2;
        		$average_15 =~s/\s+//g;	
		
		}

		if ( $frame == 20000) {
			$average_20 = $2;
        		$average_20 =~s/\s+//g;	
		
		}


		if ( $frame == 25000) {
			$average_25 = $2;
        		$average_25 =~s/\s+//g;	
		
		}

		if  ($frame == 30000) {
			$average_30 = $2;
        		$average_30 =~s/\s+//g;	
			$frame_ns_1 = $frame*0.001;
		}

	}
	
}

$average_1 = ($average_10 - $average_5)/5;
$average_2 = ($average_15 - $average_10)/5;
$average_3 = ($average_20 - $average_15)/5;
$average_4 = ($average_25 - $average_20)/5;
$average_5 = ($average_30 - $average_25)/($frame_ns_1 - 25);



while ($line_2=<FILE_2>) {

	if ($line_2=~/(\d+)\s(\S+)/) {
		$frame = $1;
		$frame =~s/\s+//g;
		
		if ( $frame == 5000) {
			$average_5a = $2;
        		$average_5a =~s/\s+//g;	
		
		}


		if ( $frame == 10000) {
			$average_10a = $2;
        		$average_10a =~s/\s+//g;	
		
		}

		if ( $frame == 15000) {
			$average_15 = $2;
        		$average_15 =~s/\s+//g;	
		
		}

		if ( $frame == 20000) {
			$average_20 = $2;
        		$average_20 =~s/\s+//g;	
		
		}


		if ( $frame == 25000) {
			$average_25 = $2;
        		$average_25 =~s/\s+//g;	
		
		}

		if  ($frame == 30000) {
			$average_30 = $2;
        		$average_30 =~s/\s+//g;	
			$frame_ns_1 = $frame*0.001;
		}

	}
	
}

$average_6 = ($average_10a - $average_5a)/5;
$average_7 = ($average_15 - $average_10a)/5;
$average_8 = ($average_20 - $average_15)/5;
$average_9 = ($average_25 - $average_20)/5;
$average_10 = ($average_30 - $average_25)/($frame_ns_1 - 25);


$big_average = ($average_1 + $average_2 + $average_3 + $average_4 + $average_5 + $average_6 + $average_7 + $average_8 + $average_9 + $average_10)*0.1;

$se = sqrt ( ( ($average_1 - $big_average)**2 + ($average_2 - $big_average)**2 + ($average_3 - $big_average)**2 + ($average_4 - $big_average)**2 + ($average_5 - $big_average)**2 + ($average_6 - $big_average)**2 + ($average_7 - $big_average)**2 + ($average_8 - $big_average)**2 + ($average_9 - $big_average)**2 + ($average_10 - $big_average)**2 )/90 );

#print "$average_5a \n";

print OUT "average flux = $big_average se = $se";
close FILE_1;
close FILE_2;
close OUT;
