#!/usr/bin/perl
#ust Math::Round;

#### Main#####
$lstart = 0.000;
$ldelta = 0.1;
$lend   = 1.000;
$title = "TI  water CNT job list";
$number_sim =3;    # 1st one is always an eq run
$eq_time = 50000;   # in time steps
$run_time = 500000; # in time steps

print "TITLE\n$title\nEND\n";
print "JOBSCRIPTS\n";
print "job_id NSTLIM RLAM subdir run_after\n";

$previous_job = "-994";
while ($lstart <= $lend+1e-8){
	$lstart = sprintf "%.3f",$lstart;
	print "\#\#\# lambda $lstart \#\#\#\n";
	for ($count = 1; $count <= $number_sim; $count++) {
		$jobnum = int($lstart*10000) + $count;
		#$jobnum = $lstart*10000 + $count;
		if ($count == 1)  {printf "%1.d %9.d  %4.3f %6s %5.d\n", $jobnum,$eq_time,$lstart,"L_$lstart",$previous_job;}
		else              {printf "%1.d %10.d  %3.3f %6s %5.d\n", $jobnum,$run_time,$lstart,"L_$lstart",$previous_job;}
		$previous_job = $jobnum; 		
	}
	$lstart = $lstart+$ldelta;	
}
 
print "\nEND\n";
