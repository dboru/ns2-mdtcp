# set terminal png 
# set terminal pdf mono
# set output 'alpha.pdf'
#awk '{print $1 "  " $5}' r1r3_q_size.out >> queue1.tr
mp=ARG1; ctcp=ARG2 ; lia=ARG3

set terminal postscript eps enhanced color 
set output 'smptcp/MP'.mp.'_'.ctcp.'_cwnd_test1bneck_15M_10M_red.eps'
#red/green/blue/magenta/cyan/yellow
# set xdata time
# set timefmt "%S"
set xlabel "Time [s]" font ",16"
set key horizontal font ",16"
set autoscale
set tics font ",16"
set ylabel "CWND [pkts]" font ", 16"
# set format y "%s"

# set title "seq number over time"
# set key reverse Left outside
set grid

# set style data linespoints
 set style line 1 lt 2 lc rgb "blue" lw 4
 set style line 2 lt 2 lc rgb "red" lw 4
 set style line 3 lt 2 lc rgb "green" lw 4
 set style line 4 lt 2 lc rgb "magenta" lw 4
 set style line 5 lt 2 lc rgb "cyan" lw 4
 set style line 6 lt 2 lc rgb "yellow" lw 4

#plot "smptcp/cwnd1.tr" using 1:2 ls 1 title mp.'-SF1' with lines,"smptcp/cwnd2.tr" using 1:2 ls 2 title #"MPTCP-SF2" with lines

plot "smptcp/cwnd1.tr" using 1:2 ls 1 title 'MP'.mp.'-SF1' with lines,"smptcp/cwnd2.tr" using 1:2 ls 2 title 'MP'.mp.'-SF2' with lines,"smptcp/cwnd3.tr" using 1:2 ls 3 title ctcp with lines


#plot "smptcp/cwnd1.tr" using 1:2 ls 1 title "MP1-cwnd1" with lines,"smptcp/cwnd1.tr" using 1:2 ls 2 title "MP1-cwnd2" with lines, "smptcp/cwnd2.tr" using 1:2 ls 3 title #"MP2-cwnd1" with lines,"smptcp/cwnd3.tr" using 1:2 ls 4 title "MP2-cwnd2" with lines,"smptcp/cwnd4.tr" using 1:2 ls 5 title "MP3-cwnd1" with lines,"smptcp/cwnd5.tr" using #1:2 ls 6 title "MP3-cwnd2" with lines

#plot "smptcp/mpcw1.tr" using 1:2 ls 1 title "MPTCP1" with lines,"smptcp/mpcw2.tr" using 1:2 ls 2 title "MPTCP2" with lines, "smptcp/mpcw3.tr" using 1:2 ls 3 #title "MPTCP3" with lines,"smptcp/mpcw4.tr" using 1:2 ls 4 title "MPTCP4" with lines,"smptcp/tcpcw.tr" using 1:2 ls 5 title "TCP" with lines

#plot "smptcp/cwnd0.tr" using 1:2 ls 1 title "SP-TCP-cwnd" with lines 