#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script  z.file";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
open (OUT1, ">vel_vs_z.dat");
open (OUT2, ">vel_vs_time.dat");
$i = 0;
while ($line_1=<FILE_1>) {

	if ($line_1=~/(\d+)\s(\S+)/) {
		$frame = $1;
		$frame =~s/\s+//g;
		$z = $2;
		$z =~s/\s+//g;
		$vel = $z - $z_old;
		$z_old = $z;
		$i++;			
	}
	if ($i == 1) {
		print OUT1 "$z 0  \n";
		print OUT2 "$frame 0 \n";		
	}

	if ($i > 1) {
		print OUT1 "$z $vel \n";
		print OUT2 "$frame $vel \n";		
	}

}
	
		
close FILE_1;
close FILE_2;
close OUT;
