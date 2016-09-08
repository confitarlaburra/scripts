#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script  script.pl flux.file ";
    exit 1; 
}

open (IN, "$ARGV[0]");
open (OUT, ">average_flux.dat");

while ($line_1=<IN>) {
	if ($line_1=~/(\d+)\s(\S+)\s(\S+)/){
		$frame = $1;
		$frame =~s/\s+//g;
		
		if ($frame == 5000){
			$flux_5a = $2;
                        $flux_5a =~s/\s+//g;
			$flux_5b = $3;
                        $flux_5b =~s/\s+//g; 
		}
		if ($frame == 10000){
			$flux_10a = $2;
                        $flux_10a =~s/\s+//g;
			$flux_10b = $3;
                        $flux_10b =~s/\s+//g; 
		}
		if ($frame == 15000){
			$flux_15a = $2;
                        $flux_15a =~s/\s+//g;
			$flux_15b = $3;
                        $flux_15b =~s/\s+//g; 
		}
		if ($frame == 20000){
			$flux_20a = $2;
                        $flux_20a =~s/\s+//g;
			$flux_20b = $3;
                        $flux_20b =~s/\s+//g; 
		}

		if ($frame == 25000){
		    $flux_25a = $2;
		    $flux_25a =~s/\s+//g;
		    $flux_25b = $3;
		    $flux_25b =~s/\s+//g;
                }


		if ($frame == 30000){
		    $flux_30a = $2;
		    $flux_30a =~s/\s+//g;
		    $flux_30b = $3;
		    $flux_30b =~s/\s+//g;
                }
	}
}
$average_1a= ($flux_10a - $flux_5a)/5;
$average_1b= ($flux_10b - $flux_5b)/5;

$average_2a= ($flux_15a - $flux_10a)/5;
$average_2b= ($flux_15b - $flux_10b)/5;

$average_3a= ($flux_20a - $flux_15a)/5;
$average_3b= ($flux_20b - $flux_15b)/5;

$average_4a= ($flux_25a - $flux_20a)/5;
$average_4b= ($flux_25b - $flux_20b)/5;

$average_5a= ($flux_30a - $flux_25a)/5;
$average_5b= ($flux_30b - $flux_25b)/5;


$big_average = ($average_1a + $average_1b + $average_2a + $average_2b + $average_3a + $average_3b + $average_4a + $average_4b + $average_5a + $average_5b)/10;
$se = sqrt ( ( ($average_1a - $big_average)**2 + ($average_1b - $big_average)**2 + ($average_2b - $big_average)**2 + ($average_2a - $big_average)**2 + ($average_3a - $big_average)**2 + ($average_3b - $big_average)**2 + ($average_4a - $big_average)**2 + ($average_4b - $big_average)**2 + ($average_5a - $big_average)**2 + ($average_5b - $big_average)**2 )/90);

print OUT "average flux = $big_average se = $se";
close IN;
close OUT;

 

