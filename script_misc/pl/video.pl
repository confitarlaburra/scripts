#!/bin/perl
$snapshots=1099;
$path="/home/jgarate/vmd/lib";
$movie_name="movie";
for($i = 0; $i <= 1099; $i++){
    system ("$path/tachyon_LINUXAMD64 $i.dat -aasamples 8 -format targa -o $i.tga"); 
    system ("convert $i.tga $i.jpg");
    system ("rm $i.tga $i.dat");
    
    
}
#system ("mencoder mf://*.jpg -mf w=800:h=600:fps=25:type=jpg -ovc copy -oac copy -o $movie_name.avi");
