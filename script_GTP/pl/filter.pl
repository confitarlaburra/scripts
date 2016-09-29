if (($ARGV[0] eq "") || ($ARGV[1] eq ""))  {
    print "Usage of this script : file filtering frq";
    exit 1; 
}
open (FILE, "$ARGV[0]");
open (OUT,">totspecial_1line.dat");
$counter =0;
while ($line=<FILE>) {
	$i++;
	if (($counter  > 0) &&  ($i % $ARGV[1]==0)) {print OUT $line;}
	$counter++;
}
close FILE;
close OUT;
