#!/usr/bin/perl


$nwaters=5;
@P1;
@P2;
@time;
$bool=1;			
$count_waters=2;
while ($count_waters <= $nwaters) {
	$file = "$count_waters.out";
	#print "water $count_waters\n";
	open ($count_waters, "$file");
	$lines=0; 
	while ($line=<$count_waters>)  {
		#print "$line";	
		if (($line=~/^(\d+\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) || ($line=~/^(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) ) { 
			#print "$1 $2 $3\n";			
			$P1[$lines]+=$4;
			$P2[$lines]+=$5;
			$time[$lines]=$1;
			#print "\#$count_waters\n";
			$lines++
		}	
       }
      print "\#$count_waters\n";
      $count_waters++;
}

$size=@P1;
for ($count = 0; $count < $size; $count++) {
	$P1[$count]/= $nwaters-1; #just for 5.5
	$P2[$count]/= $nwaters-1; #jut for 5.5
	printf "%10.4f %10.9f %10.9f\n", $time[$count], $P1[$count] ,$P2[$count];	
}

