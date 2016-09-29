#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : time series of angle";
    exit 1; 
}
open (FILE_1, "$ARGV[0]");

printf "%5s %10s\n","#Time", "Angle (0-360)";

while ($line=<FILE_1>) {
	if ($line=~/^\s+(\d+\S+)\s+(\S+)/) {	 
		$snapshot =$1;
		$snapshot =~s/\s+//g;
		$angle = $2;
		$snapshot =~s/\s+//g;
		#print "$angle\n";
		if ($angle <  0) {
			$angle = $angle + 360;
		
		}
		printf   "%10.3f %10.3f\n",$snapshot,$angle;
		
	}

	if ($line=~/^(\d+\S+)\s+(\S+)/) {	 
		$snapshot =$1;
		$snapshot =~s/\s+//g;
		$angle = $2;
		$snapshot =~s/\s+//g;
		#print "$angle\n";
		if ($angle <  0) {
			$angle = $angle + 360;
		
		}
		printf   "%10.3f %10.3f\n",$snapshot,$angle;
		
	}
}

close FILE_1;
