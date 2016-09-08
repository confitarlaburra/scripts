#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script /path/to/pdb/\n";
    exit 1; 
}


open (IN, "$ARGV[0]");
open (OUT, ">index.dat");
$i =0;
while ($line=<IN>){
      if ($line=~/^ATOM/){
 	  #print "hola";
          $segid=substr($line,72,3);
          #print $segid;
          if (($segid eq MD2) || ($segid eq LII) || ($segid eq LIf)) {
              #print $segid;
              $i++;
              $index= substr($line,5,6);
              $index=~s/\s+//g;
              $index_1= $index -1 ;
              print OUT "$index_1 ";
	  } 

      }
}
print "$i\n";
close IN;
close OUT;    
