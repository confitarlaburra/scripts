#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : namd.log.file";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
open (OUT1, ">VdW_e.dat");
open (OUT2, ">ES_e.dat");
open (OUT3, ">VdW_fx.dat");
open (OUT4, ">ES_fx.dat");
open (OUT5, ">VdW_fy.dat");
open (OUT6, ">ES_fy.dat");
open (OUT7, ">VdW_fz.dat");
open (OUT8, ">ES_fz.dat");
while ($line=<FILE_1>) {
	
	if ($line=~/^ENERGY/){	
		if ($line=~/\D+\s+(\d+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)/) {
			
			$frame = $1;
			print "$frame\n";
			$frame =~s/\s+//g;
			
			$VdW = $3;
			$VdW =~s/\s+//g;
			$ES = $2;
			$ES =~s/\s+//g;
				
		}
		if ($frame >= 0) { 
			print OUT1 "$frame $VdW \n";
			print OUT2 "$frame $ES \n";
		}
	}	

	if ($line=~/^PAIR/){

		if ($line=~/VDW_FORCE:\s+(\S+)\s+(\S+)\s+(\S+)\s+ELECT_FORCE:\s+(\S+)\s+(\S+)\s+(\S+)/) {
			$VdW_x = $1;
			$VdW_x =~s/\s+//g;
			$VdW_y = $2;
			$VdW_y =~s/\s+//g;
			$VdW_z = $3;
			$VdW_z =~s/\s+//g;
			$ES_x = $4;
			$ES_x =~s/\s+//g;
			$ES_y = $5;
			$ES_y =~s/\s+//g;
			$ES_z = $6;
			$ES_z =~s/\s+//g;
					
					
		}
		print OUT3 "$frame $VdW_x \n";
		print OUT4 "$frame $ES_x \n";
		print OUT5 "$frame $VdW_y \n";
		print OUT6 "$frame $ES_y \n";
		print OUT7 "$frame $VdW_z \n";
		print OUT8 "$frame $ES_z \n";

	}
	
}
	
		
close FILE_1;

close OUT1;
close OUT2;
close OUT3;
close OUT4;
close OUT5;
close OUT6;
close OUT7;
close OUT8;
