


use List::Util qw(max min);

sub Hist2D {}
sub Hist1D {}
sub PrintGnuplot {}

 

### MAIN ###
if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) || ($ARGV[2] eq "" ) ||  ($ARGV[3] eq "" ) ||  ($ARGV[4] eq "" ))  
{
    print "Usage of this script : chain.dat  Case_(int) Nbins_1D Nbins_2D normalize(Prob density) \n";
    print "chain.dat: output from AQP4topo_desc.tcl\n";
    print "Cases:\n";
    print "1 : Dipole magnitude and ETED\n";
    print "2 : Dipole magnitude and Hbonds\n";
    print "3 : ETED and Hbonds\n"; 
    print "Normalize:\n";
    print "1: Normalize by density (Total Count*Area)\n";
    print "0: Do not normalize\n";
    exit 1; 
}

if ( ($ARGV[1] < 0 ) || ($ARGV[1] > 3)   ) 
{
    print "Usage of this script : chain.dat  Case (int) Nbins 1D Nbins 2D \n";
    print "chain.dat: output from AQP4topo_desc.tcl\n";
    print "Cases:\n";
    print "1 : Dipole magnitude and ETED\n";
    print "2 : Dipole magnitude and Hbonds";
    print "3 : ETED and Hbonds\n"; 
    exit 1; 
}




### Fill every time####
@values1D=();
@values2D=();

if (-f $ARGV[0])
{
    # code
    @components=("0","ETEDs_Dipol","Hbond_Dipol","ETEDs_Hbond");

    $binNumber1D=$ARGV[2];
    $binNumber2D=$ARGV[3];
    $normalize=$ARGV[4];
    
#  ETED and Dipole Magnitude
    if ($ARGV[1] eq "1") 
    {
	$D1b=34;  # ETED
	$D2b=15; # dipole
    }
# hbonds and ETED
    if ($ARGV[1] eq "2") 
    {
	$D1b=45; #Dipole Magnitude
	$D2b=15; #H bonds
    }
# ETED and hbonds
    if ($ARGV[1] eq "3") 
    {
	$D1b=33; 
	$D2b=45;
    }
    
    open (FILE, "$ARGV[0]"); #timseries of values
    
    while ($line=<FILE>)
    {
	#print $line;
	if ($line=~/^\s+(\d+)/)
	{
	    $D1=substr($line,$D1b,9);
	    $D1 =~s/\s+//g;
	    $D2=substr($line,$D2b,9);
	    $D2 =~s/\s+//g;
	    print "$D2\n";		    
	    push (@values1D, $D1); #array of indexes of 1D
	    push (@values2D, $D2); #array of indexes of 2D
	} 
    }
    
    close FILE;
} else {
    print "File $ARGV[0] does not exists\n";
    exit 1;
}
Hist2D(\@values1D,\@values2D,$binNumber1D,$binNumber2D,$components[$ARGV[1]],$normalize);
Hist1D(\@values1D,$binNumber1D,substr($components[$ARGV[1]],0,5),$normalize);
Hist1D(\@values2D,$binNumber2D,substr($components[$ARGV[1]],6,5),$normalize);
### END MAIN ###

##Function Implementation##

##Function Implementation##
sub Hist1D 
{
 my (@values1D) = @{$_[0]};
 my $binNumber1D = $_[1];
 my $name = $_[2];
 my $normalize =$_[3];
 open (OUT, ">$name.dat");
 my $min1D = min @values1D;
 my $max1D = max @values1D;
 my $size = @values1D;
 my $binSize1D=($max1D-$min1D)/($binNumber1D);
 @D1hist=();
 #zero array
 for ($i = 0; $i <= $size; $i++) 
 {
     $D1hist[$i]=0.000;
 }
 #Bin Data
 for ($i = 0; $i <= $size; $i++) 
 {    
    $step1D =  int(( ($values1D[$i]-$min1D)/($binSize1D) ));
    if ($step1D >= 0 &&  $step1D < $binNumber1D) 
    {
	$D1hist[$step1D]++;
    }
 }
#Unbin and print
 print OUT "#1Hist $name\n";
 print OUT "#X    [N]\n";
 if (!$normalize) 
 {
     $NormFactor=1;
 } else {
     $NormFactor=$size*$binSize1D;
}
 for($i = 0; $i < $binNumber1D; $i++) 
 {
     $X =($i)*$binSize1D + $min1D + ($binSize1D)*0.5;
     printf OUT  ("%10.4f %10.4f\n",$X ,($D1hist[$i])/($NormFactor) );
 }
 close OUT;
}



sub Hist2D 
{
 my (@values1D) = @{$_[0]};
 my (@values2D) = @{$_[1]};
 my $binNumber1D = $_[2];
 my $binNumber2D = $_[3];
 my $name = $_[4];
 my $normalize = $_[5];
 open (OUT, ">$name.dat");
 my $min1D = min @values1D;
 my $max1D = max @values1D;
 my $min2D = min @values2D;
 my $max2D = max @values2D;
 my $size = @values1D;
 my $binSize1D=($max1D-$min1D)/($binNumber1D);
 my $binSize2D=($max2D-$min2D)/($binNumber2D);
 @D2hist=();
 #zero 2D array
 for($i = 0; $i < $binNumber1D; $i++) 
 {
     for($j = 0; $j < $binNumber2D; $j++) 
     {
	 $D2hist[$i][$j]=0.000;
     }
 }
 #Bin Data
 for ($i = 0; $i <= $size; $i++) 
 {  
     #print "$values1D[$i] $values2D[$i]\n";
     $step1D =  int(( ($values1D[$i]-$min1D)/($binSize1D) ));
     $step2D =  int(( ($values2D[$i]-$min2D)/($binSize2D) ));
     if ($step1D >= 0 &&  $step1D < $binNumber1D &&  $step2D >= 0 &&  $step2D < $binNumber2D) 
     {
	 $D2hist[$step1D][$step2D]++;
     }
 }

 
#Unbin and print
 print OUT "#2Hist $name\n";
 print OUT "#X Y  [N]\n";
 if (!$normalize) 
 {
     $NormFactor=1;
 } else {
     $NormFactor=$size*$binSize1D*$binSize2D;
 }
 for($i = 0; $i < $binNumber1D; $i++) 
 {
     $X =($i)*$binSize1D + $min1D + $binSize1D*0.5;
     for($j = 0; $j < $binNumber2D; $j++) 
     {
	 $Y =($j)*$binSize2D +$min2D + $binSize2D*0.5;
	 printf OUT  ("%10.4f %10.4f %10.4f \n",$X, $Y, ($D2hist[$i][$j])/$NormFactor);
     }
 }
 close OUT;
 PrintGnuplot($name,$min1D,$max1D,$min2D,$max2D);

}

sub PrintGnuplot 
{
    $grid_res=300;
    $grid_norm=8;
    $ytics=0.5;
    $xtics=0.5;
    $name=$_[0];
    $xMin=$_[1];
    $xMax=$_[2];
    $yMin=$_[3];
    $yMax=$_[4];
    $Xlabel=substr($name,0,5);
    $Ylabel=substr($name,6,5);	
    open (OUT, ">$name.2D.plot");
    print OUT "set dgrid3d $grid_res,$grid_res,$grid_norm;\n";
    print OUT "set xrange [$xMin:$xMax]\n";
    print OUT "set xtics $xtics\n";
    print OUT "set xtics nomirror\n";
    print OUT "set xtics out\n";
    print OUT "set xlabel \"$Xlabel [A]\"\n";
    print OUT "set yrange [$yMin:$yMax]\n";
    print OUT "set ytics $ytics\n";
    print OUT "set ytics nomirror\n";
    print OUT "set ytics out\n";
    print OUT "set ylabel \"$Ylabel [Deg]\"\n";
    print OUT "set cblabel \"P\"\n";
    print OUT "set pm3d implicit at b\n";
    print OUT "splot \"$name.dat\" using 1:2:3 with impulses notitle;\n";
    print OUT "set pm3d map\n";
    print OUT "set terminal png font 'Helvetica,15' size 1000,800\n";
    print OUT "set size 1.0, 1.0\n";
    print OUT "set output \"$name.2D.png\"\n";
    print OUT "splot \"$name.dat\" using 1:2:3 notitle\n";
    print OUT "exit\n";
    close OUT;
    $out = `gnuplot $name.2D.plot`;
    if ($out !=0) {
	print "gnuplot 2dmap failed";
    }
}
