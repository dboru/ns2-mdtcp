
set terminal postscript eps enhanced color 
set output 'smptcp/mptcp_tcp_drop_new.eps'

set xlabel "Time [s]" font ", 20"
#set xdata time
#set autoscale

set ylabel "Drops [Pkts]" font ", 20"
# set format y "%s"

# set title "seq number over time"
set key horizontal font ", 20"
#set yrange [0:10.8]
set grid
set tics font ", 20"

 set style data linespoints
 set style line 1 lt 2 lc rgb "blue" lw 4
 set style line 2 lt 2 lc rgb "red" lw 4
 set style line 3 lt 2 lc rgb "green" lw 4
 set style line 4 lt 2 lc rgb "magenta" lw 4
 set style line 5 lt 2 lc rgb "cyan" lw 4
 set style line 6 lt 2 lc rgb "yellow" lw 4


plot "smptcp/drop1.tr" using 1:2 ls 1 title "MPTCP-SF1" ,"smptcp/drop2.tr" using 1:2 ls 2 title "MPTCP-SF2" , "smptcp/drop3.tr" using 1:2 ls 3 title "TCP1" ,"smptcp/drop4.tr" using 1:2 ls 4 title "TCP2" 

