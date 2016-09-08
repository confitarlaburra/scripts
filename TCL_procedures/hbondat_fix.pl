#!/usr/bin/perl

#array with all hbonds files with repeated values
#check if each line is similar to the previous one
#if so, deletes that copy
#and finally deletes all raw files
@ps = <*.RAW>;
foreach $ps (@ps) {
   open (IN, "$ps");
   $ps=~s/.RAW//g;
   open (OUT, ">$ps.dat");
   $line_old = "hola";
   $i = 0;
   while ($line=<IN>){
      if ($line eq $line_old) { $i = 1;}else {$i = 0;}
      if ($i == 0) {print OUT "$line";}
      $line_old = $line;
   }
   close OUT;	      
   close IN;
   
} 

@ps = <*.RAW>;
foreach $ps (@ps) {
	system "rm $ps";
}
