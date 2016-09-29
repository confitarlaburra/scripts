#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : namd.log.file";
    exit 1; 
}
$counter = 0.0;
open (FILE_1, "$ARGV[0]");
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
		if ($counter <= $ARGV[1] ) {print "$snapshot $angle\n";}
		$counter++;
		
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
		if ($counter <= $ARGV[1] ) {print "$snapshot $angle\n";}
	        $counter++;
		
	}
}

close FILE_1;
