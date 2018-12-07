set terminal postscript eps
set output 'smptcp/queue.eps'
# awk '{print $1 "  " $5}' r2r4_q_size.out  >> queue1.tr
# set xdata time
# set timefmt "%S"
set xlabel "Time[s]"

set autoscale

set ylabel "Queue[pkts]"
# set format y "%s"

# set title "seq number over time"
# set key reverse Left outside
set grid

# set style data linespoints
# set style line 1 lt 2 lc rgb "red" lw 3
# set style line 2 lt 2 lc rgb "orange" lw 2

plot "smptcp/queue0.tr" using 1:2 title "queue0" with lines,"smptcp/queue1.tr" using 1:2 title "queue1" with lines
# plot "cwnd0.tr" using 1:2 title "cwnd0","cwnd1.tr" using 1:2 title "cwnd1"