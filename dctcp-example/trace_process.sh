#! /bin/sh
if [ $# -eq 3 ] 
then
    ns one_bneck_multipath.tcl $1 $2 $3
	gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $2}'   > smptcp/mpcwnd1.tr;gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $3}'   > smptcp/mpcwnd2.tr;gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $6}'   > smptcp/tcpcwnd.tr;
	perl agg_throughput.pl smptcp/out.tr.gz  4 1.1  4.1 5 2.1  5.1 0.2 > smptcp/mptcptp.tr
	perl throughput.pl smptcp/out.tr.gz  8 6.0  8.0  0.2 > smptcp/tcptp.tr
	gnuplot -c plot_figs.gp $1 $2 $3
else
    echo "Usage: ./run_sim dctcp/tcp dctcp/tcp droptail/red (3 args required)"
fi
