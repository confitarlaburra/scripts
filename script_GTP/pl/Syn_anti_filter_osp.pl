#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : angle_vs_LE_bias.file\n";
    exit 1; 
}


open (FILE_1, "$ARGV[0]");
open (OUT_1, "> GTP_anti_osp.dat");
open (OUT_2, "> GTP_syn_osp.dat");

printf OUT_1   "%10s %10s %10s %10s\n","#angle "," "," ","OSP bias";
printf OUT_2   "%10s %10s %10s %10.2f\n","#angle "," "," ","OSP bias";
while ($line=<FILE_1>) {
	if ($line=~/(\S+)\s+(\S+)/) {
		$angle =$1;
		$angle =~s/\s+//g;
		$bias =$2;
		$bias =~s/\s+//g;
		if ( ($angle >=140 && $angle <= 340)) {  ##anti
			$Counter_Anti++;
			printf OUT_1   "%10.3f %10.3f %10.3f %10.3f\n",$angle,"0.0","0.0",$bias;
		}
		if ( ($angle > 340 || $angle < 140) ) { #syn
			printf OUT_2  "%10.3f %10.3f %10.3f %10.3f\n",$angle,"0.0","0.0",$bias;
		
		}
					
	}
}



close FILE_1;
close FILE_2;
close FILE_3;
