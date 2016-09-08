#!/usr/bin/perl

#script that uses pore_axial programs and plots for every selection with gnuplot (see @atoms ) the heat maps (2D_desity."selection".eps) and 
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
#@atoms = ( "a:OW");
@atoms = ("a:OW","a:Omet","a:CMet"); # array of atoms that calcutions are going to be calculated for 
$ref = "equilibration/8.8_3nm_28CH3OH_water_min.cnf";
$pbc = "v";
$bins = "100";
$offset = "0.0";
$normfact = "rdf";
$first = "30000";
$last = "50000";
$threads = 1;
$nsim = 2;
$count = 1;
$wd = getcwd;
$dir = 'pore_axial';
# Parameters for the plots
$grid_res=300;
$grid_norm =8;
$z_min =-1.5; #pore length
$z_max = 1.5;
$r_range =$pore_radius; # pore radius




## MAIN ##

if (-d $dir)
{} else {
	system("mkdir", $dir);
}


$bool=0;
foreach $atom (@atoms) {
    $name = $atom;
    $name=~s/:/_/;
    open ($name, ">$dir/$name.axial.arg");
    print $name "\@topo ../$topo\n";
    print $name "\@pore $pore\n";
    print $name "\@atoms $atom\n";
    print $name "\@ref ../$ref\n";
    print $name "\@pbc $pbc\n";
    print $name "\@bins $bins\n";
    print $name "\@offset $offset\n";
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
    print $name "set xrange [0:$r_range]\n";
    print $name "set xtics 0.05\n";
    print $name "set xtics nomirror\n";
    print $name "set xtics out\n";
    print $name "set xlabel \"Pore Radius [nm]\"\n";
    print $name "set yrange [$z_min:$z_max]\n";
    print $name "set ytics 0.25\n";
    print $name "set ytics nomirror\n";
    print $name "set ytics out\n";
    print $name "set ylabel \" Pore Axis [nm]\"\n";
    print $name "set cblabel \"Pdf\"\n";
    print $name "set pm3d implicit at b\n";
    print $name "splot \"Axial_Radial_density.$name.out\" using 2:1:3 with impulses;\n";
    print $name "set pm3d map\n";
    print $name "set terminal postscript eps enhanced color font 'Helvetica,10'\n";
    print $name "set output \"Axial_Radial_density.$name.eps\"\n";
    print $name "splot \"Axial_Radial_density.$name.out\" using 2:1:3\n";
    print $name "exit\n";
    close $name;
 
 
    #change to pore_ads directory
    $CWD = $dir;
    
    print "\nComputing for $atom.....\n";
    
    #alarm(0);
    
    $out = `pore_ax_rad \@f  $name.axial.arg > $name.out`;
    # print "$out\n";
    if ($out !=0) {
	print "pore_axial failed";
    }
    $out = `mv  Axial_Radial_density.out  Axial_Radial_density.$name.out`;
    if ($out !=0) {
	print "mv failed";
    }
    $out = `mv Axial_density.out  Axial_density.$name.out`;
    if ($out !=0) {
	print "mv failed";
    }  
    $out = `gnuplot $name.map.plot`;
    if ($out !=0) {
	print "gnuplot 2dmap failed";
    }

    #go back CWD
    $CWD = $wd;
}



