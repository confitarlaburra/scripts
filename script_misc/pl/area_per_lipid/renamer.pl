#!/usr/bin/perl

if ($ARGV[0] eq ""){
    exit 1;
}
$file=$ARGV[0];

open (IN,"$ARGV[0]");
open (OUT,">$file.top.pdb");
$i=1;
$t=0;
while ($line=<IN>){
	if ($line=~/^ATOM/){
		
		
		if ($i < 9) {
			$line=~s/POPEL\s+\d+/POPEL   $i/;  
			print OUT $line;
			$t++;
		}
	
		if ($i >= 10 && $i <= 99) {
			$line=~s/POPEL\s+\d+/POPEL  $i/;
			print OUT $line;
			$t++;
		}

		if ($i >= 100 && $i <= 999) {
			$line=~s/POPEL\s+\d+/POPEL $i/;  
			print OUT $line;
			$t++;
		}

		if ($i >= 1000 && $i <= 9999) {
			$line=~s/POPEL\s+\d+/POPEL$i/;  
			print OUT $line;
			$t++;
		}
		
		
		
		if ($t%125==0){
			$i++;		
		}
		
		
	}

}

close IN;
close OUT;
