#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script perl script.pl volume.dat";
    exit 1; 
}

open (FILE_1, "$ARGV[0]");
open (OUT, ">volume_zeroed.dat");
$i =0;
while ($line =<FILE_1>) {
        $i++;
        #print $i;
	if ($line=~/(\d+)\s(\S+)\s(\S+)/) {
            print OUT $line;   
        } else {
      		print OUT "$i 0 0\n";
        }

}
close FILE_1;
close OUT;
