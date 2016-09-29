if ($ARGV[0] eq "") {
    print "Usage of this script : namd.log.file";
    exit 1; 
}
open (FILE, "$ARGV[0]");
open (OUT,">totspecial_1line.dat");
$counter =0;
while ($line=<FILE>) {
	if ($counter  > 0) {print OUT $line;}
	$counter++;
}
close FILE;
close OUT;
