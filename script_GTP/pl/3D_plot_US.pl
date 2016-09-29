#!/usr/bin/perl
# TI LE build runs MD for GTP #
#run it inside the TI  simulation#



#### Main#####

$lstart = 0.0; # lamba 0
$ldelta = 0.1;
$lend   = 1.0; # lambda 1
$directory_name ="/storage/GTP/topo/TI/TI_long/forward"; # super directory fo LE freeze runs

open (OUT,">3D_plot.dat");
printf OUT "%10s   %5s   %10s\n", "#Angle","lambda","PMF";
while ($lstart <= $lend+1e-8) {	
	$lstart = sprintf "%.1f",$lstart; 
        $file = "${directory_name}/LE_TI_LC_${lstart}/shifted_US/US_shifted.dat";
	$bool=0.0;
	open (FILE_1, "$file");
	$counter =0;
	while ($line=<FILE_1>) {
		$counter++;
		if (($line=~/\s+(\S+)\s+\S+\s+(\S+)/) && ($bool ==1)) {
			$angle = $1;
			$pmf   = $2 + 28.09; # shift the pmf to zero (minimun value of all PMF curves)
			$average_PMF +=$2;
			$average_angle +=$1;
			#Filter data every 100 points to plot in gnu plot
			if ($counter%100 == 0){
				$average_PMF /=100;
				$average_angle /=100;
				printf OUT "%10.2f %10.2f %10.2f\n", $angle,$lstart,$pmf;
				$average_angle =0;
				$average_PMF =0;
			} 
		} 
		$bool=1.0;
	}
	$lstart+= $ldelta;
	close FILE_1;
}
close OUT;

#Gnu plot script

open (PLOT, ">gnuplot.plot");
print PLOT "set xlabel \"Degrees\"\;\n";
print PLOT "set ylabel \"{/Symbol l}\"\;\n";
print PLOT "set zlabel \"PMF [kJ/mol]\"\ rotate left;\n";
print PLOT "set dgrid3d 11,90\;\n";
print PLOT "set pm3d at b\;\n";
print PLOT "set palette defined (0 \"blue\", 25 \"white\", 50 \"red\")\;\n";
print PLOT "set cblabel \"[kJ/mol]\"\;\n";
print PLOT "set xrange [0:360]\;\n";
print PLOT "set view 60,347;\n";
print PLOT "splot \"3D_plot.dat\" with lines\;\n";
print PLOT "set term postscript eps enhanced monochrome\;\n";
print PLOT "set output \"mono.eps\"\;\n";
print PLOT "replot\;\n";
system ("gnuplot gnuplot.plot");


 
