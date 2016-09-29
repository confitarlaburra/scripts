#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : namd.log.file";
    exit 1; 
}

$Counter_Syn=  0.0;
$Counter_Anti = 0.0;
open (FILE_1, "$ARGV[0]");
open (OUT_1, ">anti_time.dat");
open (OUT_2, ">syn_time.dat");
while ($line=<FILE_1>) {
	if ($line=~/(\S+)\s+(\S+)/) {	 
		$angle =$2;
		$angle =~s/\s+//g;
		$time = $1;
		$time =~s/\s+//g;
		$time  =  sprintf  "%.2f", $time;
		#print "$time $angle\n";
		if ( ($angle >=140 && $angle <= 340)) {			
			$Counter_Anti++;
			if ($Counter_Anti >= 1) { $log_counter_Anti = log($Counter_Anti); } else {$log_counter_Anti = 0};
			#print "$Counter_Anti\n";
			#print OUT_1 "$time $log_counter $Counter_Anti\n";
		}
		print OUT_1 "$time $log_counter_Anti $Counter_Anti\n";
		if ( ($angle > 340 || $angle < 140)) {
			$Counter_Syn++;
			if ($Counter_Syn >= 1) {$log_counter_Syn = log($Counter_Syn)} else {$log_counter_Syn = 0} ;
			#print OUT_2 "$time $log_counter $Counter_Syn\n";		
		}
		print OUT_2 "$time $log_counter_Syn  $Counter_Syn\n";
					
	}
}
print "$Counter_Syn $Counter_Anti\n";

close FILE_1;
close OUT_1;
close OUT_2;
