 #! /usr/local/bin/awk -f

 {print "Don't Panic!"}
 
 awk '{print $1 "  " $5}' smptcp/r1r3_q_size.out  >> smptcp/queue0.tr
 awk '{print $1 "  " $5}' smptcp/r2r4_q_size.out  >> smptcp/queue1.tr

 awk '{print $1 "  " $2}' smptcp/trace.tr  >> smptcp/cwnd0.tr
 awk '{print $1 "  " $3}' smptcp/trace.tr  >> smptcp/cwnd1.tr
 awk '{print $1 "  " $4}' smptcp/trace.tr  >> smptcp/alpha0.tr
 awk '{print $1 "  " $5}' smptcp/trace.tr  >> smptcp/alpha1.tr

perl agg_throughput.pl smptcp/out.tr.gz  4 1.1  4.1 5 2.1  5.1 0.1 > smptcp/mpflow.tr; perl agg_throughput.pl smptcp/out.tr.gz  8 6.0  8.0  0.1 > smptcp/tcpflow.tr;
gnuplot with cmd line arguments
#gnuplot -c plot_thrput.gp  TCP TCP

To process zipped files 

gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $2}' > smptcp/cwnd0.tr

BEGIN { s=0; FS = " "} { nl++ } { s=s+$c } END {print "sum = " s "; N = " nl "; Avg = " s/nl}

gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $2}' > smptcp/cwnd1.tr; gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $3}' > smptcp/cwnd2.tr;


 perl throughput.pl smptcp/out.tr.gz  3 0.0  3.0  0.1 > smptcp/flow1.tr;perl throughput.pl smptcp/out.tr.gz  4 1.0  4.0  0.1 > smptcp/flow2.tr;

 gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $2}' > smptcp/cwnd1.tr; gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $3}' > smptcp/cwnd2.tr; gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $4}' > smptcp/cwnd3.tr; gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $5}' > smptcp/cwnd4.tr ;gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $6}' > smptcp/cwnd4.tr; gzcat smptcp/trace.tr.gz | awk '{print $1 "  " $7}' > smptcp/cwnd5.tr



 perl throughput.pl smptcp/out.tr.gz  4 1.1  4.1  0.1 > smptcp/flow1.tr;perl throughput.pl smptcp/out.tr.gz  5 2.1  5.1  0.1 > smptcp/flow2.tr;perl throughput.pl smptcp/out.tr.gz  8 6.0  8.0  0.1 > smptcp/tcp1.tr;perl throughput.pl smptcp/out.tr.gz  9 7.0  9.0  0.1 > smptcp/tcp2.tr

 perl throughput.pl smptcp/out.tr.gz  4 1.1  4.1  0.1 > smptcp/flow1.tr;perl throughput.pl smptcp/out.tr.gz  5 2.1  5.1  0.1 > smptcp/flow2.tr;perl throughput.pl smptcp/out.tr.gz  8 6.0  8.0  0.1 > smptcp/tcp1.tr;perl throughput.pl smptcp/out.tr.gz  9 7.0  9.0  0.1 > smptcp/tcp2.tr


perl drop_process.pl smptcp/out.tr.gz  1.1  4.1 > smptcp/drop1.tr;perl drop_process.pl smptcp/out.tr.gz  2.1  5.1 > smptcp/drop2.tr;perl drop_process.pl smptcp/out.tr.gz  6.0  8.0 > smptcp/drop3.tr;perl drop_process.pl smptcp/out.tr.gz  7.0  9.0  > smptcp/drop4.tr

 gnuplot plot_thrput.gp ; gnuplot cwnd_plot.gp


 open smptcp/clia10M-mpdctcp_2spdctcp_cwnd.eps ;open smptcp/clia10M-mpdctcp_2spdctcp_thput.eps


 Add columns of two files 

 awk 'NR==FNR{a[NR]=$2;next}{print $1,$2+a[FNR]}' file1 file2

 Add columns of multiple files 

 paste flow1.tr flow2.tr flow3.tr flow4.tr | awk '{ s=$2; for(i=4; i<=NF; i+=2) s+=$i; print $1, s }'

Sum column items in the same row 
 paste *.track | awk '{sum=0; for (i=2; i<=NF; i++) { sum+= $i } print sum}' > sum.track

