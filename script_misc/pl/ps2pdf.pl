#!/usr/bin/perl

#if ($ARGV[0] eq "") {
#    print "Usage of this script  script.pl path/to/ps files\n";
#    exit 1; 
#}


#@ps=<$ARGV[0]/*ps>;
#print "$ARGV[0]";
@ps = <*.ps>;

foreach $ps (@ps) {
        print "$ps\n";
	system ("ps2pdf $ps");
} 


