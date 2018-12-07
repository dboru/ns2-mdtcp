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
set tcp_window 100
# run_time (sec)
# set run_time 10.0
# pktSize (bytes)
set pktSize 1400
# max buffer size 
set q_size 30
#### DCTCP Parameters ####
# DCTCP_K (pkts)
set DCTCP_K 10
# DCTCP_g (0 < g < 1)
set DCTCP_g 0.0625
# ackRatio
set ackRatio 1

##### Switch Parameters ####
set drop_prio_ false
set deque_prio_ false

#Queue/RED set bytes_ false
#Queue/RED set queue_in_bytes_ true
Queue/RED set mean_pktsize_ [expr $pktSize+40]
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
# Agent/TCP set tcpTick_ 0.01
Agent/TCP set minrto_ 0.2 ; # minRTO = 200ms

Agent/TCP/FullTcp set nodelay_ true; # disable Nagle
Agent/TCP/FullTcp set segsperack_ $ackRatio;
Agent/TCP/FullTcp set interval_ 0.04
Agent/TCP/FullTcp set spa_thresh_ 3000;
Agent/TCP set ecnhat_ true
# Agent/TCPSink set ecnhat_ true
Agent/TCP set ecnhat_g_ $DCTCP_g;

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
$ns duplex-link $n0_0 $r1 10Mb 5ms DropTail
$ns duplex-link $n0_1 $r1 10Mb 5ms DropTail
$ns duplex-link $r1 $r2 10Mb 5ms RED
$ns duplex-link $n1_0 $r2 10Mb 5ms DropTail
$ns duplex-link $n1_1 $r2 10Mb 5ms DropTail
$ns queue-limit $r1 $r2 30


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
$tcp0 set window_ 100 
$ns attach-agent $n0_0 $tcp0
set tcp1 [new Agent/TCP/FullTcp/Sack/Multipath]
$tcp1 set window_ 100
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

# $ns connect $tcp0 $sink0
# $ns connect $tcp1 $sink1

$mptcpsink listen




proc finish {} {
	global ns f 
	# global nf
	$ns flush-trace
	close $f
	# close $nf

 #    set awkcode {
 #        {
 #           if ($1 == "r" && NF == 20) {  
 #             if ($3 == "1" && $4 == "10" && $5 == "tcp") { 
 #               print $2, $18 >> "mptcp"
 #             } 
 #             if ($3 == "2" && $4 == "11" && $5 == "tcp") { 
 #               print $2, $18 >> "mptcp"
 #             } 
 #           }
 #           if ($1 == "r" && NF == 17) {  
 #             if ($3 == "6" && $4 == "10" && $5 == "tcp") { 
 #               print $2, $11 >> "normal-tcp1"
 #             } 
 #             if ($3 == "8" && $4 == "11" && $5 == "tcp") { 
 #               print $2, $11 >> "normal-tcp2"
 #             } 
 #          }
 #        }
 #    } 
	# exec rm -f mptcp normal-tcp1 normal-tcp2
 #  exec awk $awkcode out.tr
    # exec xgraph -M -m -nl mptcp normal-tcp1 normal-tcp2 
	exit
}

$ns at 0.1 "$ftp start"        
$ns at 30 "finish"

$ns run
