@plot = <*.plot>;

foreach $plot (@plot) {
        print "$plot\n";
	system ("gnuplot $plot");
} 


