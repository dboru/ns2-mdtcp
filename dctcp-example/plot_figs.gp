set terminal postscript eps enhanced color
mp=ARG1; 
ctcp=ARG2; 
qtype=ARG3 

set output 'smptcp/mp'.mp.'_'.ctcp.'_cwnd_1bneck_'.qtype.'.eps'
set key horizontal maxcols 1
# set title "seq number over time"
set key font ", 16"
#set yrange [0:10.8]
set grid
set tics font ", 16"
set tics font ",16"
set ylabel "CWND [pkts]" font ", 16"
set xlabel "Time [s]" font ",16"
 set style line 1 lt 2 lc rgb "blue" lw 4
 set style line 2 lt 2 lc rgb "red" lw 4
 set style line 3 lt 2 lc rgb "green" lw 4
 set style line 4 lt 2 lc rgb "magenta" lw 4
 set style line 5 lt 2 lc rgb "cyan" lw 4
 set style line 6 lt 2 lc rgb "yellow" lw 4
 set style line 7 lt 2 lc rgb "pink" lw 4
 set style line 8 lt 2 lc rgb "violet" lw 4
 set style line 9 lt 2 lc rgb "orange" lw 4
 set style line 10 lt 2 lc rgb "navy" lw 4

titles= 'MPTCP-SF1 MPTCP-SF2 TCP'
files = 'smptcp/mpcwnd1.tr smptcp/mpcwnd2.tr smptcp/tcpcwnd.tr'
plot for [i=1:words(files)] word(files, i) using 1:2 ls i title word(titles,i)  with lines
set output 'smptcp/mp'.mp.'_'.ctcp.'_tp_1bneck_'.qtype.'.eps'
set ylabel "Throughput [Mb/s]" font ", 16"
titles= 'MPTCP TCP'
files = 'smptcp/mptcptp.tr smptcp/tcptp.tr'
plot for [i=1:words(files)] word(files, i) using 1:2 ls i title word(titles,i)  with lines