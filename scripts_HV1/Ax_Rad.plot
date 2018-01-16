set dgrid3d 300,300,20;
set xrange [0:10]
set xtics 5
set xtics nomirror
set xtics out
set xlabel "Pore Radius [A]"
set yrange [-25.48:25.48]
set ytics 10
set ytics nomirror
set ytics out
set ylabel " Pore Axis [A]"
set cbtics 0.8
set cbrange [0:1.6]
set cblabel "P/P0"
set pm3d implicit at b
splot "AxialRadDens.dat" using 2:1:3 with impulses;
set pm3d map
#set terminal postscript eps enhanced color font 'Helvetica,10'
set terminal png font 'Helvetica,30' size 1000,800
set size 0.95, 1.0 
set output "Axial_Radial_density.s_OW.png"
splot "AxialRadDens.dat" using 2:1:3 notitle
exit
