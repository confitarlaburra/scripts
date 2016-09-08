#!/usr/bin/perl
#Script to rename CNTs counting every 4 atoms as one residue (output from CNT builder from VMD) 23-10-12

if ($ARGV[0] eq "") {
    print "Usage of this script /path/to/pdb/\n";
    exit 1; 
}


open (IN, "$ARGV[0]");
open (OUT, ">$ARGV[0].corrected.pdb");
$i=0;
$j=1;
$counter =1;
$res_name = "CCC";
while ($line=<IN>){		
      if ($line=~/^ATOM/){		
          if ($counter <= 9)                         {$line=~s/C\s+CNT\sX\s+\d+/C$j  $res_name X   $counter/; print OUT $line;}
	  if (($counter > 9) && ($counter <= 99) )   {$line=~s/C\s+CNT\sX\s+\d+/C$j  $res_name X  $counter/;  print OUT $line;}
	  if (($counter > 99) && ($counter <= 999) ) {$line=~s/C\s+CNT\sX\s+\d+/C$j  $res_name X $counter/;   print OUT $line;}
	  $i++;
	  $j++;	
	  if ($i%4 == 0) {$counter++; $j=1;}

	}
}          
