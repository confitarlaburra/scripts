#!/usr/bin/perl

if ( ($ARGV[0] eq "")) {#|| ($ARGV[1]) eq "" ) {
    print "Usage of this script : scrpt.pl time_dihed.dat time\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]");
$transition = 0.0;
$old_angle = 0.0;
$angle = 0.0;
$snapshot = 0.0;
$t=0;
open (OUT,">transitions.dat");
$counter_time = 0.0;
$second_counter_time = 0.0;
$state = 0;
$old_state =0;
printf OUT "%8s %10s %10s %10s\n","#Time","Trans","Tot","Dihed";
while ($line=<FILE_1>) {
	if ($line=~/(\d+\S+)\s+(\S+)/) {
		$counter_time =0.0;
		$snapshot =$1;
		$snapshot =~s/\s+//g;
		$angle = $2;
		#print "$angle\n";
	#	if ($second_counter_time <= $ARGV[1] ) { 
                	if ($t ==1) {			
                		if ($angle >=210 && $angle <= 240) {$state = anti;}
				if ($angle >=40 && $angle <= 70)   {$state = syn;}
			}
			#print "$state\n";
			if ($state eq anti && $old_state eq syn) {$counter_time++; $transition++;}
			if ($state eq syn && $old_state eq anti) {$counter_time++; $transition++;}
			if ($counter_time >= 1) { printf  OUT "%8.3f %8.3f %8.3f %8.3f\n",$snapshot, "-50", $transition, $angle;} else { printf  OUT "%8.3f %8.3f %8.3f %8.3f\n",$snapshot, "-10", $transition, $angle;}
			$old_state=$state;
			$t =1;
		}
		
		$second_counter_time++;
#	}
}
print "Total transitions: $transition\n";
close FILE_1;
close OUT;
