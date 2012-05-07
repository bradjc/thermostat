set terminal postscript enhanced eps solid color font "Helvetica,32" size 11.11in,6.94in
set output "lines.eps"

set style line 1 lt 1 ps 1 lw 10 pt 7 lc rgb '#000000'
set style line 2 lt 1 ps 1 lw 10 pt 7 lc rgb '#1F75FE'
set style line 3 lt 1 ps 1 lw 10 pt 7 lc rgb '#B4674D'
set style line 4 lt 1 ps 1 lw 10 pt 7 lc rgb '#1CAC78'
set style line 5 lt 1 ps 1 lw 10 pt 7 lc rgb '#FF7538'
set style line 6 lt 1 ps 1 lw 10 pt 7 lc rgb '#EE204D'
set style line 7 lt 1 ps 1 lw 10 pt 7 lc rgb '#926EAE'
set style line 8 lt 1 ps 1 lw 10 pt 7 lc rgb '#FCE883'
set style line 9 lt 1 ps 1 lw 10 pt 7 lc rgb '#7366BD'
set style line 10 lt 1 ps 1 lw 10 pt 7 lc rgb '#FFAACC'
set style line 11 lt 1 ps 1 lw 10 pt 7 lc rgb '#0D98BA'
set style line 12 lt 1 ps 1 lw 10 pt 7 lc rgb '#C0448F'
set style line 13 lt 1 ps 1 lw 10 pt 7 lc rgb '#FF5349'
set style line 14 lt 1 ps 1 lw 10 pt 7 lc rgb '#5D76CB'
set style line 15 lt 1 ps 1 lw 10 pt 7 lc rgb '#F0E891'
set style line 16 lt 1 ps 1 lw 10 pt 7 lc rgb '#95918C'
set style line 17 lt 1 ps 1 lw 10 pt 7 lc rgb '#FDD9B5'
set style line 18 lt 1 ps 1 lw 10 pt 7 lc rgb '#FDDB6D'
set style line 19 lt 1 ps 1 lw 10 pt 7 lc rgb '#1DACD6'
set style line 20 lt 1 ps 1 lw 10 pt 7 lc rgb '#FC2847'
set style line 21 lt 1 ps 1 lw 10 pt 7 lc rgb '#F75394'
set style line 22 lt 1 ps 1 lw 10 pt 7 lc rgb '#C5E384'
set style line 23 lt 1 ps 1 lw 10 pt 7 lc rgb '#FFAE42'
set style line 24 lt 1 ps 1 lw 10 pt 7 lc rgb '#FDBCB4'
set style line 25 lt 1 ps 1 lw 10 pt 7 lc rgb '#1A4876'
set style line 26 lt 1 ps 1 lw 10 pt 7 lc rgb '#C8385A'
set style line 27 lt 1 ps 1 lw 10 pt 7 lc rgb '#EDD19C'

#set style fill solid border rgb "black"

set auto x
set auto y

set xdata time
set timefmt "%m %d"
set format x "%m/%d"
set timefmt "%s"

set border 3 lw 1
set xtics nomirror
set ytics nomirror


set key below


set xlabel "Date"
set ylabel "Lines"

