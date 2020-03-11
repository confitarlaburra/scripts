$min1D=1;
$max1D=20;
$min2D=-1.0;
$max2D=1.0;
@dats = <Dip*.dat>;

foreach $dat (@dats) {
    print "plotting $dat\n";
    PrintGnuplot($dat,$min1D,$max1D,$min2D,$max2D);

}

sub PrintGnuplot {
    $grid_res=300;
    $grid_norm=8;
    $ytics=1.0;
    $xtics=2;
    $name=$_[0];
    $xMin=$_[1];
    $xMax=$_[2];
    $yMin=$_[3];
    $yMax=$_[4];
    $Xlabel="|Dipole| (A.e)";
    $Ylabel="P1 (cos O)";	
    open (OUT, ">$name.2D.plot");
    #print OUT "set loadpath \'/home/jgarate/opt/gnuplot-palettes\'";
    print OUT "set dgrid3d $grid_res,$grid_res,$grid_norm;\n";
    #print OUT "set xrange [$xMin:$xMax]\n";
    print OUT "set xtics $xtics\n";
    print OUT "set xtics nomirror\n";
    print OUT "set xtics out\n";
    print OUT "set xlabel \"$Xlabel [A]\"\n";
    print OUT "set yrange [$yMin:$yMax]\n";
    print OUT "set ytics $ytics\n";
    print OUT "set ytics nomirror\n";
    print OUT "set ytics out\n";
    print OUT "set ylabel \"$Ylabel\"\n";
    print OUT "set cblabel \"P\"\n";
    #print OUT "set cbrange [0:0.4]\n";
    print OUT "set cbtics 0.2\n";
    print OUT "set pm3d implicit at b\n";
    print OUT "splot \"$name\" using 1:2:3 with impulses notitle;\n";
    print OUT "set pm3d map\n";
    print OUT "set terminal png font 'Arial,25' size 1000,800\n";
    print OUT "set size 1.0, 1.0\n";
    print OUT "set output \"$name.2D.png\"\n";
    print OUT "splot \"$name\" using 1:2:3 notitle\n";
    print OUT "exit\n";
    close OUT;
    $out = `gnuplot $name.2D.plot`;
    if ($out !=0) {
	print "gnuplot 2dmap failed";
    }
}
