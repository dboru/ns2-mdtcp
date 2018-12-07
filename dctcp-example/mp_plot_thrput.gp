
set terminal postscript eps enhanced color 
set output 'smptcp/tmpdctcp_tp.eps'

set xlabel "Time [s]" font ", 20"

#set autoscale

set ylabel "Throughput [Mb/s]" font ", 20"
# set format y "%s"

# set title "seq number over time"
set key horizontal font ", 20"
set yrange [0:10.8]
set grid
set tics font ", 20"

# set style data linespoints
 set style line 1 lt 2 lc rgb "blue" lw 4
 set style line 2 lt 2 lc rgb "red" lw 4
 set style line 3 lt 2 lc rgb "green" lw 4
 set style line 4 lt 2 lc rgb "magenta" lw 4
 set style line 5 lt 2 lc rgb "cyan" lw 4
 set style line 6 lt 2 lc rgb "yellow" lw 4


#plot "smptcp/thput.tr" using 1:2 ls 1 title "SP-TCP" with lines

#plot "smptcp/flow1.tr" using 1:2 ls 1 title "MP1-Flow1" with lines,"smptcp/flow2.tr" using 1:2 ls 2 title "MP1-Flow2" with lines, "smptcp/flow3.tr" using 1:2 ls 3 title #"MP2-Flow1" with lines,"smptcp/flow4.tr" using 1:2 ls 4 title "MP2-Flow2" with lines,"smptcp/flow5.tr" using 1:2 ls 5 title "MP3-Flow1" with #lines,"smptcp/flow6.tr" using #1:2 ls 6 title "MP3-Flow2" with lines

#plot "smptcp/flow1.tr" using 1:2 ls 1 title "MP1-Flow1" with lines,"smptcp/flow2.tr" using 1:2 ls 2 title "MP1-Flow2" with lines, "smptcp/flow3.tr" using 1:2 ls 3 title #"MP2-Flow1" with lines,"smptcp/flow4.tr" using 1:2 ls 4 title "MP2-Flow2" with lines,"smptcp/flow5.tr" using 1:2 ls 5 title "TCP" with lines


plot "smptcp/flow1.tr" using 1:2 ls 1 title "MPDCTCP-SF1" with lines,"smptcp/flow2.tr" using 1:2 ls 2 title "MPDCTCP-SF2" with lines

#plot "smptcp/mp1.tr" using 1:2 ls 1 title "MPTCP1" with lines,"smptcp/mp2.tr" using 1:2 ls 2 title "MPTCP2" with lines, "smptcp/mp3.tr" using 1:2 ls 3 title #"MPTCP3" with lines,"smptcp/mp4.tr" using 1:2 ls 4 title "MPTCP4" with lines,"smptcp/flow5.tr" using 1:2 ls 5 title "TCP" with lines, "smptcp/cum.tr" using #1:2 ls 6 title "Sum" with lines

#plot "smptcp/flow1.tr" using 1:2 ls 1 title "Flow1" with lines,"smptcp/#flow2.tr" using 1:2 ls 2 title "Flow2" with lines