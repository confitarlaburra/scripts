#!/usr/bin/perl

#script that uses pore_ads programs and plots for every selection with gnuplot (see @atoms ) the heat maps (2D_desity."selection".eps) and 
# a full 3D plot 3D_hist.eps

BEGIN {
 unshift @INC,"/home/jgarate/bin/perl_modules"

}
use Cwd;
use File::chdir;

$gathered = 0;
$static_base_name = 1;
$base_name ="gather/gathered";
$topo = "8.8_3nm_28CH3OH_water.top";
$pbc = "v";
$bins = "100";
$offset = "0.0";
# cutoff = pore radius + ads_radius
$pore_radius ="0.505";
$normfact = "rdf";
$pore = "1:a";
@atoms = ("1:a","a:Omet","a:CMet"); # array of atoms that calcutions are going to be calculated for 
#@atoms = ("a:Cet2");
$ref = "equilibration/8.8_3nm_28CH3OH_water_min.cnf";
$pbc = "v";
$bins = "100";
$offset = "0.0";
$cutoff = "0.73";
$normfact = "rdf";
$first = "30000";
$last = "50000";
$threads = 1;
$grid_res=300;
$grid_norm =8;
$nsim = 2;
$count = 1;
$wd = getcwd;
$dir = 'pore_ads';



## MAIN ##

if (-d $dir)
{} else {
	system("mkdir", $dir);
}


open (Dplot, ">$dir/3D_hist.plot");
print Dplot "set dgrid3d $grid_res,$grid_res,$grid_norm;\n";
print Dplot "set xrange [-2.62:2.62]\n";
print Dplot "set xtics 0.5\n";
print Dplot "set xtics nomirror\n";
print Dplot "set xtics out\n";
print Dplot "set xlabel \"X [nm]\"\n";
print Dplot "set yrange [-2.65:2.65]\n";
print Dplot "set ytics 0.5\n";
print Dplot "set ytics nomirror\n";
print Dplot "set ytics out\n";
print Dplot "set ylabel \" Y [nm]\"\n";
print Dplot "set ztics nomirror\n";
print Dplot "set ztics out\n";
print Dplot "set zlabel \" pdf\" rotate left \n";
print Dplot "set terminal postscript eps enhanced color font 'Helvetica,10'\n";
print Dplot "set output \"3D_hist.eps\"\n";


$bool=0;
foreach $atom (@atoms) {
    $name = $atom;
    $name=~s/:/_/;
    open ($name, ">$dir/$name.ads.arg");
    print $name "\@topo ../$topo\n";
    print $name "\@pore $pore\n";
    print $name "\@atoms $atom\n";
    print $name "\@ref ../$ref\n";
    print $name "\@pbc $pbc\n";
    print $name "\@bins $bins\n";
    print $name "\@offset $offset\n";
    print $name "\@cutoff $cutoff\n";
    print $name "\@pore_radius $pore_radius\n";
    print $name "\@normfact $normfact\n";
    print $name "\@first $first\n";
    print $name "\@last $last\n";
    print $name "\@threads $threads\n";
    print $name "\@traj\n";
    $count=1;
    while ($count <= $nsim) {
	if ($gathered) {
	    print $name  "../${base_name}\n";
	    $count++;
	} else {
	    print $name  "../${base_name}_${count}.trc.gz\n";	
	    $count++;
	}
    }
    close $name;   
    
    open ($name, ">$dir/$name.map.plot");
    print $name "set dgrid3d $grid_res,$grid_res,$grid_norm;\n";
    print $name "set xrange [-2.62:2.62]\n";
    print $name "set xtics 0.5\n";
    print $name "set xtics nomirror\n";
    print $name "set xtics out\n";
    print $name "set xlabel \"X [nm]\"\n";
    print $name "set yrange [-2.64:2.64]\n";
    print $name "set ytics 0.5\n";
    print $name "set ytics nomirror\n";
    print $name "set ytics out\n";
    print $name "set ylabel \" Y [nm]\"\n";
    print $name "set cblabel \"Pdf\"\n";
    print $name "set pm3d implicit at b\n";
    print $name "splot \"2Ddensity.$name.out\" with impulses;\n";
    print $name "set pm3d map\n";
    print $name "set terminal postscript eps enhanced color font 'Helvetica,10'\n";
    print $name "set output \"2Ddensity.$name.eps\"\n";
    print $name "splot \"2Ddensity.$name.out\"\n";
    print $name "exit\n";
    close $name;
    # full 3d plot
    
    if (!$bool) {
	print Dplot "splot \"2Ddensity.$name.out\" with impulses ";
    } else {
	print Dplot ", \"2Ddensity.$name.out\" with impulses";
    }
    $bool = 1; 

    #change to pore_ads directory
    $CWD = $dir;
    
    print "\nComputing for $atom.....\n";
    
    #alarm(0);
        
    $out = `pore_ads \@f  $name.ads.arg > $name.out`;
    print "$out\n";
    if ($out !=0) {
	print "pore_ads failed";
    }
    $out = `mv 2Ddensity.out 2Ddensity.$name.out`;
    if ($out !=0) {
	print "mv failed";
    }
    $out = `mv Radial_density.out Radial_density.$name.out`;
    if ($out !=0) {
	print "mv failed";
    }  
    $out = `mv adsorbed_TS.out adsorbed_TS.$name.out`;
    if ($out !=0) {
	print "mv failed";
    }
#    $out = `gnuplot $name.map.plot`;
    if ($out !=0) {
	print "gnuplot 2dmap failed";
    }
    #go back CWD                                                                                                   
    $CWD = $wd;
}


print Dplot "\nexit\n";
close Dplot;
$CWD = $dir;
if($X) {
 #   $out =`gnuplot 3D_hist.plot`;
    if ($out !=0) {
	print "gnuplot 3d_hist failed";
    }
}
$CWD = $wd;
