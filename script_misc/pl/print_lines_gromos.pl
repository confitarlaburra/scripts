#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : namd.log.file\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]");
$i=0;
while ($line=<FILE_1>) {
	#print "hola";
	if ($line=~/^\s+(\d+\S+)\s+(\S+)/) {	 
		$snapshot =$1;
		$snapshot =~s/\s+//g;
		$angle = $2;
		$snapshot =~s/\s+//g;
		
		if ($i == 0) {print "$snapshot $angle\n";}
		if ($i%5 == 0) {print "$snapshot $angle\n"}
		$i++;
	}
}

close FILE_1;
