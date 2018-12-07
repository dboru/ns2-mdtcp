#
#
# Script for mptcp/dctcp simulation
#
#   Dejene B. Oljira <oljideje@kau.se>
#
# ns-2 trace file ECN Flags meaning
# ``E'' Congestion Experienced (CE) 
# ``N'' ECN-Capable-Transport (ECT) indications in the IP header,
# ``C'' ECN-Echo 
# ``A'' for Congestion Window Reduced (CWR) in the TCP header. 

# The first character of one trace record indicates the action:
# +: a packet arrives at a queue (it may or may not be dropped !)
# -: a packet leaves a queue
# r: a packet is received into a queue (buffered)
# d: a packet is dropped from a queue
# The last 4 fields contains:
# source id: id of sender (format is: x.y = node x and transport agent y)
# receiver id: id of receiver (format is: x.y = node x and transport agent y)
# sequence number: useful to determine if packet was new or a retransmission
# packet id: is always increasing - usefule to determine the number of packets lossed.
# The packet size contains the number of bytes in the packet

# The ns-2 TCPs require setting window sizes and buffer sizes in number of packets.
set ns [new Simulator]
remove-all-packet-headers
add-packet-header IP TCP
#
# specify to print mptcp option information
#
# Trace set show_tcphdr_ 2

##In case TCP , BWxRTT
# set queueSize [expr int (ceil (($mean_link_delay * 2.0 * $link_rate * 1000000000.0/8.0) / ($pktSize+40.0)))]
#set tcpwin_ [expr 4 * int (ceil (($mean_link_delay * 2.0 * $link_rate * 1000000000.0/8.0) / ($pktSize+40.0)))]
#Agent/TCP set window_ $tcpwin_
# setup trace files
#
# set f [open out.tr w]
# $ns trace-all $f
# set nf [open out.nam w]
# $ns namtrace-all $nf


# samp_int (sec)
set samp_int 0.01
# link_cap (Mbps)
set link_cap 10Mb
set link_bneck 1Mb
# link_delay (ms)
set link_delay 2ms
set link_delay_2 2ms

set queue_type RED
# set link_delay 5ms
# tcp_window (pkts)
set tcp_window 100
# run_time (sec)
# set run_time 10.0
# pktSize (bytes)
set pktSize 1460
# max buffer size 
set q_size 30
set dq_size 100000

### DCTCP Parameters ####
# DCTCP_K (pkts)
set DCTCP_K 10
# DCTCP_g (0 < g < 1)
set DCTCP_g 0.0625
# ackRatio
set ackRatio 1

##### Switch Parameters ####
set drop_prio_ false
set deque_prio_ false

Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
# Mean packet size
Queue/RED set mean_pktsize_ [expr $pktSize+40]
# Set to "true" to mark packets by setting the congestion indication bit
 # in packet headers rather than drop packets.
Queue/RED set setbit_ true
# Disable gentle mode
Queue/RED set gentle_ false
# Exponential weighted moving avergage constant
Queue/RED set q_weight_ 1.0
Queue/RED set mark_p_ 1.0
# RED min threshold
Queue/RED set thresh_ $DCTCP_K
# RED max threshold
Queue/RED set maxthresh_ $DCTCP_K
Queue/RED set drop_prio_ $drop_prio_
Queue/RED set deque_prio_ $deque_prio_

DelayLink set avoidReordering_ true

set mpdctcp false
set cdctcp  false

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
# Delayed ack interval
Agent/TCP/FullTcp set interval_ 0.04
Agent/TCP/FullTcp set spa_thresh_ 3000;
Agent/TCP set ecnhat_ true
# Agent/TCPSink set ecnhat_ true
Agent/TCP set ecnhat_g_ $DCTCP_g;


set trace_dir /Users/oljideje/workspace/repos/ns-install-osx/dctcp-example/smptcp

#
# setup trace files
#
set f [open "|gzip > $trace_dir/out.tr.gz" w]
$ns trace-all $f

set mtrace [open "|gzip > $trace_dir/trace.tr.gz" w]
set alpha [open "|gzip > $trace_dir/alpha.tr.gz" w]
# Queue options
# Queue set limit_ $q_size


# End from DCTCP script 

#
# mptcp sender
#
set MPTCP_Core_Nodes 2
set MPTCP_subflows 2
# create MPTCP sender and receiver nodes 
for {set i 0} {$i < $MPTCP_Core_Nodes} {incr i} {
    set n($i) [$ns node]
    
    for {set j 0} {$j < $MPTCP_subflows} {incr j} {
      set n_($i-$j) [$ns node]

      $ns multihome-add-interface $n($i) $n_($i-$j)

    }   
}

# create competing (c) senders node 

set NTCP 4
# 6->8 and 7->9
for {set i 0} {$i < $NTCP} {incr i} {
    set c($i) [$ns node]
    if {$i <= 1} {
      set ctcp($i) [new Agent/TCP/FullTcp/Sack]
      $ctcp($i) set window_ $tcp_window
      $ctcp($i) set dctcp_ $cdctcp
      $ns attach-agent $c($i) $ctcp($i)
      set ftpc($i) [new Application/FTP]
      $ftpc($i) attach-agent $ctcp($i)
      # set ctcp0 $ctcp($i)

    } elseif {$i > 1 && $i <= 3} {
      set ctcp($i) [new Agent/TCP/FullTcp/Sack]
      $ns attach-agent $c($i) $ctcp($i)
      $ctcp($i) set dctcp_ $cdctcp
      $ns connect $ctcp([expr $i-2]) $ctcp($i)
      $ctcp($i) listen
    }        
}


# Create switche nodes 

set NSwitches 4
for {set i 0} {$i < $NSwitches} {incr i} {
    set sw($i) [$ns node]  
}

# connect switches

for {set i 0} {$i < [expr $NSwitches - 2]} {incr i} {
  
    $ns duplex-link $sw($i) $sw([expr $i+2]) $link_cap $link_delay $queue_type
    $ns queue-limit $sw($i) $sw([expr $i+2]) $q_size
  

  # Tracing a queue
# set redq [[$ns link $node_(r1) $node_(r2)] queue]
# set tchan_ [open all.q w]
# $redq trace curq_
# $redq trace ave_
# $redq attach $tchan_
  # connect competing node sender to switch
  

  $ns duplex-link $c($i) $sw($i) $link_cap $link_delay DropTail
  $ns queue-limit $c($i) $sw($i) $dq_size
  # connect competing node receiver to switch
  $ns duplex-link $c([expr $i+2]) $sw([expr $i+2]) $link_cap $link_delay DropTail
  $ns queue-limit $c([expr $i+2]) $sw([expr $i+2]) $dq_size
}


# connect nodes to switches

for {set i 0} {$i < $MPTCP_Core_Nodes} {incr i} {

    for {set j 0} {$j <$MPTCP_subflows} {incr j} {
      if {$i == 0} {
         $ns duplex-link $n_($i-$j) $sw($j) $link_cap $link_delay DropTail
         $ns queue-limit $n_($i-$j) $sw($j) $dq_size
      } elseif {$i == 1} {
        $ns duplex-link $n_($i-$j) $sw([expr $j+2]) $link_cap $link_delay DropTail
        $ns queue-limit $n_($i-$j) $sw([expr $j+2]) $dq_size

      } 
    }   
}

# HOST options
Agent/TCP set window_ $tcp_window
Agent/TCP set windowInit_ 2
Agent/TCP set packetSize_ $pktSize
# create MPTCP senders and receivers
# set tracer_ [new Trace/Var]
# $tracer_ attach [open cwndtrace.tr w]
set ftp [new Application/FTP]


for {set i 0} {$i < $MPTCP_Core_Nodes} {incr i} {
  set mptcp($i) [new Agent/MPTCP]
  # set tcp($i) [new Agent/TCP/FullTcp/Sack/Multipath]

  for {set j 0} {$j < $MPTCP_subflows} {incr j} {
    set tcp_($i-$j) [new Agent/TCP/FullTcp/Sack/Multipath]
    $tcp_($i-$j) set dctcp_ $mpdctcp
    $tcp_($i-$j) set window_ $tcp_window
    $ns attach-agent $n_($i-$j) $tcp_($i-$j) 
    $mptcp($i) attach-tcp $tcp_($i-$j)
    
    # $tcp_($i-$j) trace cwnd_ $tracer_
    # puts "$tcp_($i-$j)"
    if {$i == 0  && $j == 0} {
      set tcp($j) $tcp_($i-$j)
    } elseif {$i == 0  && $j == 1} {
      set tcp($j) $tcp_($i-$j)
    }
    # $tcp_($i-$j) attach $mtrace; # attach to TCP Agent
    # $tcp_($i-$j) tracevar cwnd_
    
    # $tcp_($i-$j) tracevar dctcp_alpha_

    } 

  $ns multihome-attach-agent $n($i) $mptcp($i)
  
  if {$i == 0} {
    
    $ftp attach-agent $mptcp($i)
  } elseif { $i == 1} {
    $ns multihome-connect $mptcp([expr $i-1]) $mptcp($i)
    $mptcp($i) listen
  }
   
}


proc myTrace {file} {
  global ns N samp_int tcp mtrace MPTCP_Core_Nodes MPTCP_subflows ctcp alpha
  
  set now [$ns now]

  for {set i 0} {$i < [expr $MPTCP_Core_Nodes-1]} {incr i} {

    for {set j 0} {$j < $MPTCP_subflows} {incr j} {
      if {$j == 0} {
        puts -nonewline $file "$now [$tcp($j) set cwnd_]"
        puts -nonewline $file " [$tcp([expr $j + 1]) set cwnd_]"
        puts -nonewline $file " [$ctcp($j) set cwnd_]"

        # puts -nonewline $file " [$tcp($j) set rtt_]"
        # puts -nonewline $file " [$tcp([expr $j + 1]) set rtt_]"
        # puts -nonewline $file " [$tcp($j) set rttvar_]"
        # puts -nonewline $file " [$tcp([expr $j + 1]) set rttvar_]"
        # puts -nonewline $file " [$tcp($j) set ssthresh_]"
        # puts $file " [$tcp([expr $j + 1]) set ssthresh_]"

        
      } else {
        puts $file " [$ctcp($j) set cwnd_]" 
      }

    }
  } 
 
 $ns at [expr $now+$samp_int] "myTrace $file"


}


proc finish {} {
	global ns f mtrace
	$ns flush-trace
	close $f  
  close $mtrace 
  exit   
}

$ns at $samp_int "myTrace $mtrace"
$ns at 0.0 "$ftp start"
# $ns at 5.0 "$ftpc(0) start" 
# $ns at 10.0 "$ftpc(0) stop"
$ns rtmodel-at 5.0 down $sw(1) $sw(3)
$ns rtmodel-at 10.0 up $sw(1) $sw(3)
# $ns at 2.51 "$ftpc(1) start" 
# $ns at 4.5 "$ftp stop"       
$ns at 15.0 "finish"
$ns run
