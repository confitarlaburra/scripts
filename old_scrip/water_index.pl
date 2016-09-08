#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script /path/to/pdb/\n";
    exit 1; 
}


open (IN, "$ARGV[0]");
open (OUT, ">water_index.dat");

while ($line=<IN>){
      
      if ($line=~/^ATOM/){
 	  print "hola";
          $resid=substr($line,17,4);
          print $resid;
          if ($resid eq TIP3) {
              $index= substr($line,5,6);
              $index=~s/\s+//g;
              $index_1= $index -1 ;
              print OUT "$index_1 ";
	  } 

      }
}

close IN;
close OUT;    
