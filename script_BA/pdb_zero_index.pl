#!/usr/bin/perl

if ($ARGV[0] eq ""  || $ARGV[1] eq "" ) {
    print "Usage of this script /path/to/pdb/ resname\n";
    exit 1; 
}

$resname = "$ARGV[1]";
open (IN, "$ARGV[0]");
open (OUT, ">index.dat");

while ($line=<IN>){
      
      if ($line=~/^ATOM/){
          $resid=substr($line,17,4);
	  $resid =~s/\s+//g;
	  if ($resid eq $resname) {
	      $index= substr($line,5,6);
              $index=~s/\s+//g;
              $index_1= $index -1 ;
              print OUT "$index_1 ";
	  } 

      }
}

close IN;
close OUT;    
