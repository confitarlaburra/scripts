#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : angle  vs bias file\n";
    exit 1; 
}
# Calculates Delta G from anti to syn, using the bias MD.
$Syn=0.0;
$Anti=0.0;
$Counter=  0.0;
$Counter_Anti= 0.0;
$Counter_Syn = 0.0;
$kb = 0.008314511212;
$T = 298;
$kbT=$kb*$T;
$exp_aver = 0.0; 
open (FILE_1, "$ARGV[0]");
while ($line=<FILE_1>) {
	if ($line=~/(\S+)\s+(\S+)/) {	 
		$angle =$1;
		#print "$angle\n";
		$angle =~s/\s+//g;
		$bias = $2;
		$bias =~s/\s+//g;
		#print "$bias\n";
		#print "$snapshot $angle\n";
		$exp_aver = $exp_aver + exp($bias/($kbT));
		$counter++;
		#print "$exp_aver\n";
		if ( ($angle >=140 && $angle <= 340) && ($bias != 0) ) {
			#$elevated = exp(-$bias/($kbT));
			$Anti = $Anti + exp($bias/($kbT));
			#$Counter_Anti++;
			
			#print " $angle $bias $Anti \n";
		}
		if ( ($angle > 340 || $angle < 140) && ($bias != 0) ) {
			$Syn = $Syn + exp($bias/($kbT));
			#$Counter_Syn++;
			#print " $angle $bias $Syn \n";		
		}
					
	}
}

#print "$Anti $Syn $exp_aver\n";
#print "$Counter_Anti $Counter_Syn $counter\n";

$exp_aver = $exp_aver/$counter;
$Anti = $Anti/$counter;
$Syn  = $Syn/$counter;

#print "$exp_aver $Anti $Syn\n";

$P_anti = $Anti/$exp_aver; 
$P_syn =  $Syn/$exp_aver;



#print "$P_anti $P_syn \n";

$G_anti_syn = -$kbT*log($P_syn/$P_anti);
#$G_anti = -$kbT*log($P_anti);
#$G_syn =  -$kbT*log($P_syn);

$P_anti =  sprintf  "%.2f", $P_anti;
$P_syn  =  sprintf  "%.2f", $P_syn;
$G_anti_syn  =  sprintf  "%.2f", $G_anti_syn;
print "$counter\n";
print  " Prob Anti = $P_anti\nProb Syn= $P_syn\nDetal G Anti-Syn = $G_anti_syn\n";

#print "G Anti = $G_Anti \nG Syn = $G_Syn \nDelta Syn Anti $Delta_G\n";
close FILE_1;
