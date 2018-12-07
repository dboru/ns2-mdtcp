# set terminal png 
# set terminal pdf mono
# set output 'alpha.pdf'

set terminal postscript eps
set output 'smptcp/alpha.eps'

# set xdata time
# set timefmt "%S"
set xlabel "Time[s]"

set autoscale

set ylabel "Alpha"
# set format y "%s"

# set title "seq number over time"
# set key reverse Left outside
set grid

# set style data linespoints
# set style line 1 lt 2 lc rgb "red" lw 3
# set style line 2 lt 2 lc rgb "orange" lw 2

plot "smptcp/alpha0.tr" using 1:2 title "alpha0" with lines,"smptcp/alpha1.tr" using 1:2 title "alpha1" with lines