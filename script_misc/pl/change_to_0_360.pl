#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : namd.log.file";
    exit 1; 
}
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
		print "$snapshot $angle\n";
		
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
		print "$snapshot $angle\n";
		
	}
}

close FILE_1;
