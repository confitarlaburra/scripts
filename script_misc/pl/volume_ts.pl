#!/bin/perl
$dcd_file ="/home/jgarate/MD2_water/eq3.dcd";
$index_file ="index.dat";
$pdb_file ="/home/jgarate/MD2_water/MD2_solv_box_ion.pdb";
system ("/home/jgarate/vmd/lib/plugins/LINUXAMD64/bin/catdcd4.0/catdcd $dcd_file > catdcd.out");
open (CATDCD, "catdcd.out");

while ($line = <CATDCD> ) {
       if ($line=~/^Total/){
           if ($line=~/Total\s+frames:\s+(\d+)/) {
                        $frame = $1;
			print "$frame frames \n";
			$frame =~s/\s+//g;
           }
       }
}
close $CATDCD;

open (VOLUME, ">Volume_area.dat");

for($i = 1; $i <= $frame; $i++){
    system ("/home/jgarate/vmd/lib/plugins/LINUXAMD64/bin/catdcd4.0/catdcd -i $index_file -first $i -last $i -otype pdb -s $pdb_file -o $i.pdb $dcd_file");
    system ("./pdb_to_xyzr -h $i.pdb > $i.xyzr");
    system ("/home/jgarate/3v/bin/AllChannelExc.exe -i $i.xyzr -b 6 -s 1.5 -t 1.5 -g 0.75 -n 2 > $i.out");
    open (IN, "$i.out");
    $f = 0;
    @volumes=(); 
    @surfaces=();
    while ($line = <IN> ) {
          $f = 1;
          if ($line=~/\d+\s+\S+\s+\S+\S+\s+(\S+)\s+(\S+)/) {
                $volume= $1 ;
                $volume=~s/\s+//g;
                $surface= $2 ;
                $surface=~s/\s+//g;
                push (@volumes, "$volume");
                push (@surfaces, "$surface"); 
           } 
    }
    sub max {
            my($max)=shift(@_);
            foreach $temp (@_) {
               $max = $temp if $temp > $max;
            }
            return($max);
    }
   if ($f == 1) {
   	$volume = max @volumes;
   	$surface = max @surfaces;
   	print VOLUME "$i $volume $surface\n";
   } else {
        print VOLUME "$i 0 0 \n";
   }
   close IN;
   system ("rm $i.out $i.pdb $i.xyzr ");
     
}
close VOLUME;
