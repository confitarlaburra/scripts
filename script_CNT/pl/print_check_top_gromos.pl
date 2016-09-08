#!/usr/bin/perl

if (($ARGV[0] eq "") ||  ($ARGV[1] eq "") ||  ($ARGV[2] eq "")) {
    print "Usage of this script : chek_top.out property number\n";
    exit 1; 
}
open (FILE_1, "$ARGV[0]");
$bool=0;
$i=0;
$num=$ARGV[2];
print "# index      IMP     Energy\n";
while ($line=<FILE_1>) {
	if ($line=~/^\d+\s$ARGV[1]/) {$bool =1;} 
	if ( ($line=~/^\s+\d+/) && ($bool==1) ){
		$i++;			
		$property =substr($line,69,16);
		$property=~s/\s+//g;
		$energy=substr($line,85,16);
		$energy =~s/\s+//g;
		printf("%7d %10.5f %10s\n" ,$i, $property, $energy);
	}
	if  ($i>=$num) {$bool =0;}
}
close FILE_1;
