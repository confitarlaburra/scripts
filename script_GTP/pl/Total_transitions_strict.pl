#!/usr/bin/perl

if ( ($ARGV[0] eq "")) {
    print "Usage of this script : scrpt.pl time_dihed.dat time  time_limit (optional)\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]");
$transition = 0.0;
$old_angle = 0.0;
$angle = 0.0;
$snapshot = 0.0;
$t=0;
if  ($ARGV[1] ne "") {open (OUT,">transitions.${ARGV[1]}.dat");} else {open (OUT,">transitions_total.dat");}
$counter_time = 0.0;
$second_counter_time = 0.0;
$state = 0;
$old_state =0;
printf OUT "%8s %10s %10s %10s\n","#Time","Trans","Tot","Dihed";
while ($line=<FILE_1>) {
	if ($line=~/(\d+\S+)\s+(\S+)/) {
		$second_counter_time++;
		$counter_time =0.0;
		$snapshot =$1;
		$snapshot =~s/\s+//g;
		$angle = $2;
		if ($second_counter_time <= $ARGV[1] || $ARGV[1] eq "") { 
                	if ($t ==1) {			
                		if ($angle >=190 && $angle <= 290) {$state = anti;}
				if ($angle >=340 || $angle <= 130)   {$state = syn;}
			}
			if ($state eq anti && $old_state eq syn) {$counter_time++; $transition++;}
			if ($state eq syn && $old_state eq anti) {$counter_time++; $transition++;}
			if ($counter_time >= 1) { printf  OUT "%8.3f %8.3f %8.3f %8.3f\n",$snapshot, "-50", $transition, $angle;} else { printf  OUT "%8.3f %8.3f %8.3f %8.3f\n",$snapshot, "-10", $transition, $angle;}
			$old_state=$state;
			$t =1;
		}
	}
}
print "Total transitions: $transition\n";
close FILE_1;
close OUT;
