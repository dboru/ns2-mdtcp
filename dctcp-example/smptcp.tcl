#
#
# sample script for mptcp implementation on ns-2
#
#      Yoshifumi Nishida <nishida@sfc.wide.ad.jp>
#
#
set ns [new Simulator]

#
# specify to print mptcp option information
#
Trace set show_tcphdr_ 2

#
# setup trace files
#
set f [open out.tr w]
$ns trace-all $f
# set nf [open out.nam w]
# $ns namtrace-all $nf

# From DCTCP script
set r1r3_q_file r1r3_q_size.out 
set r2r4_q_file r2r4_q_size.out
# samp_int (sec)
set samp_int 0.0001
# q_size (pkts)
set q_size 20
# link_cap (Mbps)
set link_cap 10Gb
# link_delay (ms)
set link_delay 0.25
# set link_delay 5ms
# tcp_window (pkts)
set tcp_window 1256
# run_time (sec)
set run_time 10.0
# pktSize (bytes)
set pktSize 1460
set B 250

#### DCTCP Parameters ####
# DCTCP_K (pkts)
set DCTCP_K 65
# DCTCP_g (0 < g < 1)
set DCTCP_g 0.0625
# ackRatio
set ackRatio 1

##### Switch Parameters ####
set drop_prio_ false
set deque_prio_ false

set trace_dir /Users/oljideje/workspace/repos/ns-install-osx/dctcp-example/smptcp

#
# setup trace files
#
set f [open $trace_dir/out.tr w]
$ns trace-all $f

set mtrace [open $trace_dir/trace.tr w]
# Queue options
Queue set limit_ $q_size

Queue/DropTail set mean_pktsize_ [expr $pktSize+40]
Queue/DropTail set drop_prio_ $drop_prio_
Queue/DropTail set deque_prio_ $deque_prio_

#Queue/RED set bytes_ false
#Queue/RED set queue_in_bytes_ true
Queue/RED set mean_pktsize_ $pktSize
Queue/RED set setbit_ true
Queue/RED set gentle_ false
Queue/RED set q_weight_ 1.0
Queue/RED set mark_p_ 1.0
Queue/RED set thresh_ $DCTCP_K
Queue/RED set maxthresh_ $DCTCP_K
Queue/RED set drop_prio_ $drop_prio_
Queue/RED set deque_prio_ $deque_prio_

DelayLink set avoidReordering_ true

# set Queue Type
set queue_type RED

# End from DCTCP script 

#
# mptcp sender
#
set n0 [$ns node]
set n0_0 [$ns node]
set n0_1 [$ns node]
$n0 color red
$n0_0 color red
$n0_1 color red
$ns multihome-add-interface $n0 $n0_0
$ns multihome-add-interface $n0 $n0_1

#
# mptcp receiver
#
set n1 [$ns node]
set n1_0 [$ns node]
set n1_1 [$ns node]
$n1 color blue
$n1_0 color blue
$n1_1 color blue
$ns multihome-add-interface $n1 $n1_0
$ns multihome-add-interface $n1 $n1_1



#
# intermediate nodes 
#
set r1 [$ns node]
set r2 [$ns node]
set r3 [$ns node]
set r4 [$ns node]

# HOST options
Agent/TCP set window_ $tcp_window
Agent/TCP set windowInit_ 2
Agent/TCP set packetSize_ $pktSize
Agent/TCP/FullTcp set segsize_ $pktSize
Agent/TCP set dctcp_ true
Agent/TCP set ecn_ 1
Agent/TCP set old_ecn_ 1
Agent/TCP/FullTcp set spa_thresh_ 0
Agent/TCP set slow_start_restart_ true
Agent/TCP set windowOption_ 0
Agent/TCP set tcpTick_ 0.01
Agent/TCP set minrto_ 0.2 ; # minRTO = 200ms
#    Agent/TCP set minrto_ $min_rto
#    Agent/TCP set maxrto_ 2

Agent/TCP/FullTcp set nodelay_ true; # disable Nagle
Agent/TCP/FullTcp set segsperack_ $ackRatio;
Agent/TCP/FullTcp set interval_ 0.04
Agent/TCP/FullTcp set spa_thresh_ 3000;
Agent/TCP set ecnhat_ true
# Agent/TCPSink set ecnhat_ true
Agent/TCP set ecnhat_g_ $DCTCP_g;


$ns duplex-link $n0_0 $r1 $link_cap $link_delay $queue_type
$ns duplex-link $r1 $r3   $link_cap $link_delay $queue_type
# $ns queue-limit $r1 $r3 $B
$ns duplex-link $n1_0 $r3 $link_cap $link_delay $queue_type

$ns duplex-link $n0_1 $r2 $link_cap $link_delay $queue_type
$ns duplex-link $r2 $r4   $link_cap $link_delay $queue_type
# $ns queue-limit $r2 $r4 $B
$ns duplex-link $n1_1 $r4 $link_cap $link_delay $queue_type

#
# create mptcp sender
#
#     1. create subflows with Agent/TCP/FullTcp/Sack/Multipath
#     2. attach subflow on each interface
#     3. create mptcp core 
#     4. attach subflows to mptcp core
#     5. attach mptcp core to core node 
#     6. attach application to mptcp core
#
set tcp0 [new Agent/TCP/FullTcp/Sack/Multipath]
# $tcp0 set window_ 100 
$ns attach-agent $n0_0 $tcp0
set tcp1 [new Agent/TCP/FullTcp/Sack/Multipath]
# $tcp1 set window_ 100
$ns attach-agent $n0_1 $tcp1
set mptcp [new Agent/MPTCP]
$mptcp attach-tcp $tcp0
$mptcp attach-tcp $tcp1
$ns multihome-attach-agent $n0 $mptcp
set ftp [new Application/FTP]
$ftp attach-agent $mptcp


#
# create mptcp receiver
#
set mptcpsink [new Agent/MPTCP]
set sink0 [new Agent/TCP/FullTcp/Sack/Multipath]
$ns attach-agent $n1_0 $sink0 
set sink1 [new Agent/TCP/FullTcp/Sack/Multipath]
$ns attach-agent $n1_1 $sink1 
$mptcpsink attach-tcp $sink0
$mptcpsink attach-tcp $sink1
$ns multihome-attach-agent $n1 $mptcpsink
$ns multihome-connect $mptcp $mptcpsink
$mptcpsink listen

# queue monitoring
set qf_size [open $trace_dir/$r1r3_q_file w]
set qmon_size [$ns monitor-queue $r1 $r3 $qf_size $samp_int]
[$ns link $r1 $r3] queue-sample-timeout

set qf_size [open $trace_dir/$r2r4_q_file w]
set qmon_size [$ns monitor-queue $r2 $r4 $qf_size $samp_int]
[$ns link $r2 $r4] queue-sample-timeout

proc myTrace {file} {
  global ns N samp_int tcp0 tcp1 mtrace
    
  set now [$ns now]

  set cwnd0 [$tcp0 set cwnd_]
  set alpha0 [$tcp0 set dctcp_alpha_]
  set cwnd1 [$tcp1 set cwnd_]
  set alpha1 [$tcp1 set dctcp_alpha_]

  puts -nonewline $file "$now $cwnd0"
  puts -nonewline $file " $cwnd1"
  puts -nonewline $file " $alpha0"
  puts  $file " $alpha1"
 
  $ns at [expr $now+$samp_int] "myTrace $file"
}





proc finish {} {
	global ns f
	global nf
	$ns flush-trace
	close $f
	
  #   set awkcode {
  #        {
  #         puts "inside calculate ..."
  #            if ($1 == "r" && NF == 20) {  
  #              if ($3 == "9" && $4 == "5" && $6 == "tcp") { 
  #                print $2, $20 >> "thput"
  #              } 
  #              if ($3 == "8" && $4 == "4" && $6 == "tcp") { 
  #                print $2, $20 >> "thput"
  #              } 
  #            }
            
  #         }
  #     }
  # exec awk $awkcode out.tr
 
     
  exit   
}

$ns at $samp_int "myTrace $mtrace"
$ns at 0.0 "$ftp start"        
$ns at 1.0 "finish"
$ns run
