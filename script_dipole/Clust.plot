set dgrid3d 300,300,20;
set xrange [2:5.5]
set xtics 0.5
set xtics nomirror
set xtics out
set xlabel "Cut-off [A]"
set yrange [1:14]
set ytics 1
set ytics nomirror
set ytics out
set ylabel "Cluster Index"
set cbtics 0.5
set cbrange [0:1] 
set cblabel "P"
set pm3d implicit at b
splot "ClusDens.dat" using 1:2:3 with impulses;
set pm3d map
#set terminal postscript eps enhanced color font 'Helvetica,10'
set terminal png font 'Helvetica,25' size 1000,800
set size 0.95, 1.0 
set output "ClusDens.png"
splot "ClusDens.dat" using 1:2:3 notitle
#exit
