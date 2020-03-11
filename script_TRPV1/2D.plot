#set loadpath '/home/jgarate/opt/gnuplot-palettes'
#load 'viridis.pal'
#set encoding utf8
set dgrid3d 300,300,8;
set xrange [0:20]
set xtics 5
set xtics nomirror
set xtics out
set xlabel '|Dipole| (A.e)';
set yrange [-1:1]
set ytics 0.5
set ytics nomirror
set ytics out
set ylabel "P1 (cos O)"
set cbtics 0.5
set cbrange [0:1] 
set cblabel "P"
set pm3d implicit at b
splot "Dip.P1z.D.631.to.643.dat" using 1:2:3 with impulses;
set pm3d map
set terminal png font 'Arial,25' size 1000,800
set size 0.95, 1.0 
set output "Dip.P1z.D.631.to.643.dat.png"
splot "Dip.P1z.D.631.to.643.dat" using 1:2:3 notitle
#exit
