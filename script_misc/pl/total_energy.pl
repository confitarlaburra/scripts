#!/usr/bin/perl

if (($ARGV[0] eq "") || ($ARGV[1]) eq "") {
    print "Usage of this script : namd.log.file eq_steps\n";
    exit 1; 
}

sub average_sd {
            my $sum = 0;
            $size = @_;
            foreach $temp (@_) {
               $sum = $sum + $temp;
            }
	    my $average = $sum/$size;
            my $sum = 0;
	    foreach $temp (@_) {
               $sum = $sum + ($temp-$average)**2;
            }
	    my $sd = sqrt($sum/$size);
            $av_sd = "$average $sd";
            return($av_sd);
}
open (FILE_1, "$ARGV[0]");
open (OUT, ">total_energy.$ARGV[0].$ARGV[1].dat");
open (OUT2, ">average_sd.$ARGV[0].$ARGV[1].dat");
$i =0;
@average_list=();
while ($line=<FILE_1>) {
	if ($line=~/^ENERGY/ && ($i >= $ARGV[1]) ){	
		if ($line=~/\D+\s+(\d+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) {
			
			$frame = $1;
			$frame =~s/\s+//g;
			$total = $2;
			$total =~s/\s+//g;
			print OUT "$frame $total\n";
			push (@average_list, "$total");
				
		}
	}	

	if ($line=~/^ENERGY/) {$i ++;}
}
	
#foreach	 $temp (@average_list) {
#	print "$temp\n";
#}

$average = average_sd @average_list;
print "$ARGV[1] last frames average sd $average\n";
print OUT2 "$ARGV[1] last frames average sd $average\n";	
close FILE_1;
close OUT;
close OUT2;

