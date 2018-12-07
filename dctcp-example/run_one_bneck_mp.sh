#! /bin/sh
if [ $# -eq 3 ] 
then
    ns one_bneck_multipath.tcl $1 $2 $3
	gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $2}'   > smptcp/mpcwnd1.tr;gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $3}'   > smptcp/mpcwnd2.tr;gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $6}'   > smptcp/tcpcwnd.tr;
	perl agg_throughput.pl smptcp/out.tr.gz  4 1.1  4.1 5 2.1  5.1 0.1 > smptcp/mptcptp.tr
	perl throughput.pl smptcp/out.tr.gz  7 6.0  7.0  0.1 > smptcp/tcptp.tr
    mp='TCP'
    ctcp='TCP'
	if [ "$1" == "dctcp" ]
		then 
		  mp='DCTCP'
	else
	    mp='TCP'
	fi

	if [ "$2" == "dctcp" ]
		then 
		  ctcp='DCTCP'
	else
	    ctcp='TCP'
	fi

	echo "$mp $ctcp"

	gnuplot -c plot_figs_one_bneck_mp.gp $mp $ctcp $3
else
    echo "Usage: ./run_sim dctcp/tcp dctcp/tcp droptail/red (3 args required)"
fi
