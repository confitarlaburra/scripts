#!/usr/bin/perl

if ($ARGV[0] eq ""  || $ARGV[1] eq "" ) {
    print "Usage of this script /path/to/pdb/ resname to be removed\n";
    exit 1; 
}

my $resname = "$ARGV[1]";
open (IN, "$ARGV[0]");
open (INDEX, ">index.dat");
open (PDB, ">No.$resname.pdb");
my $index =0;
while ($line=<IN>){
      
      if (($line=~/^ATOM/) || ($line=~/^HETATM/)) {
          my $resid=substr($line,17,4);
	  $resid =~s/\s+//g;
	  if ($resid ne $resname) {
	      print INDEX "$index ";
	      print PDB $line
	  }
	  $index++;
      }
}

close IN;
close OUT;    
