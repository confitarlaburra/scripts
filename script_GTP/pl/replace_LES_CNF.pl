if (($ARGV[0] eq "") || ($ARGV[1] eq "" )  || ($ARGV[2] eq "" ) )  {
    print "Usage of this script : scrip.pl cnf_file trs_file LES_time_bias\n";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
open (FILE_2, "$ARGV[1]");
$name = "$ARGV[0].frozenLES.$ARGV[2].cnf";
print "$name\n";
open (OUT, "> $name");

$x=0;

while ($line=<FILE_1>) {
	if ($x == 0) { print OUT "$line"};	
	if ($line=~/NVISLE/) { $x = 1;}
}




$i =0;
$t=-1;
$n =0;
$d =0;
while ($line=<FILE_2>) { 
        if (($t==0) && ($line=~/\s+(\S+)/)) {		
		$NCONLE = $1;
		$NCONLE =~s/\s+//g;
		$t++;
				
	}
	if (($t>=2) && ($line=~/\s+(\d+)\s+(\d+)/) && ($n == 1)) {
		
		if ($d >= 2) {
			print OUT  "$line";
			$t++;
		}
		$d++;
	}

	if ($t >= ($NCONLE)) { $t = -1; $n= 0; $d=0;}
	if ($line=~/NCONLE/) {$t =0;}
	if ($line=~/NVISLE/) {$t ++;}
	if ($line=~/TIMESTEP/) {$h =1;}
	if (($h==1) && ($line=~/\s+(\S+)\s+(\S+)/)) {
		$time_step = $1;
		$time_step =~s/\s+//g; 
		$h=0;
		$time =$2;
                $time =~s/\s+//g;
                $time = sprintf "%.2f", $time;
	} 
	if (($time == $ARGV[2])) {$n = 1;}
}

print OUT "END";
close $OUT; 
