set terminal postscript enhanced eps solid color font "Helvetica,32" size 11.11in,6.94in
set output "lines.eps"

set style line 1 lt 1 ps 1 pt 7 lc rgb "red"
set style line 2 lt 1  ps 1 pt 7 lc rgb "blue"
set style line 3 lt 1  ps 1 pt 7 lc rgb "#33cc33"
set style line 4 lt 1  ps 1 pt 7 lc rgb "#993399"
set style line 5 lt 1  ps 1 pt 7 lc rgb "brown"
set style line 6 lt 1  ps 1 pt 7 lc rgb "pink"
set style line 7 lt 1  ps 1 pt 7 lc rgb "orange"
set style line 8 lt 1  ps 1 pt 7 lc rgb "cyan"
set style line 9 lt 1 ps 1 pt 7 lc rgb "violet"
set style line 10 lt 1 ps 1 pt 7 lc rgb "green"
set style line 11 lt 1  ps 1 pt 7 lc rgb "yellow"

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

