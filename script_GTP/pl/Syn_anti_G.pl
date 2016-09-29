#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : namd.log.file\n";
    exit 1; 
}

$Counter_Syn=  0.0;
$Counter_Anti = 0.0;
$counter =0.0;
$kb = 0.008314511212;
$T = 298;
$kbT=$kb*$T; 
open (FILE_1, "$ARGV[0]");
while ($line=<FILE_1>) {
	if ($line=~/(\S+)\s+(\S+)/) {
		$counter ++;	 
		$angle =$2;
		$angle =~s/\s+//g;
		#print $angle
		#print "$snapshot $angle\n";
		if ( ($angle >=140 && $angle <= 340)) {
			$Counter_Anti++;
			#print " $angle $Counter_Anti \n";
		}
		if ( ($angle > 340 || $angle < 140) ) {
			$Counter_Syn++;
			#print " $angle $Counter_Syn \n";		
		}
					
	}
}


print "$counter\n";
$Delta_G = -$kbT*log($Counter_Syn/$Counter_Anti);	
$Delta_G = sprintf "%.2f", $Delta_G ;
print "Anti = $Counter_Anti \n Syn = $Counter_Syn \nDelta Syn Anti $Delta_G\n";
close FILE_1;
