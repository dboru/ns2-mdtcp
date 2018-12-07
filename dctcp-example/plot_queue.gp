# set terminal png 
# set terminal pdf mono
# set output 'alpha.pdf'
#awk '{print $1 "  " $5}' r1r3_q_size.out >> queue1.tr
mp=ARG1; ctcp=ARG2

set terminal postscript eps enhanced color 
set output 'smptcp/queue_mptcp_tcp_1bneck_15M_10M_red.eps'
#red/green/blue/magenta/cyan/yellow
# set xdata time
# set timefmt "%S"
set xlabel "Time [s]" font ",16"
set key horizontal font ",16"
set autoscale
set tics font ",16"
set ylabel "Queue length [pkts]" font ", 16"
# set format y "%s"

# set title "seq number over time"
# set key reverse Left outside
set grid
#gzcat qmptcp_tcp.tr.gz | awk '{print $2 " " $3/1500}' > qmptcp_tcp.tr
# set style data linespoints
 set style line 1 lt 2 lc rgb "blue" lw 4
 set style line 2 lt 2 lc rgb "red" lw 4
 set style line 3 lt 2 lc rgb "green" lw 4
 set style line 4 lt 2 lc rgb "magenta" lw 4
 set style line 5 lt 2 lc rgb "cyan" lw 4
 set style line 6 lt 2 lc rgb "yellow" lw 4



plot "smptcp/qmptcp_tcp.tr" using 1:2 ls 1 title 'MPTCP-TCP' with lines,
#plot "smptcp/qmptcp_dctcp.tr" using 1:2 ls 2 title 'MPTCP-DCTCP' with lines,
#plot "smptcp/qmpdctcp_tcp.tr" using 1:2 ls 3 title 'MPDCTCP-TCP' with lines,
#plot "smptcp/qmpdctcp_dctcp.tr" using 1:2 ls 4 title 'MPDCTCP-DCTCP' with lines


