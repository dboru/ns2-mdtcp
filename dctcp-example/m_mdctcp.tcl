#
#
# sample script for mptcp implementation on ns-2
#
#      Yoshifumi Nishida <nishida@sfc.wide.ad.jp>
#
#

# The ns-2 TCPs require setting window sizes and buffer sizes in number of packets.
set ns [new Simulator]
remove-all-packet-headers
add-packet-header IP TCP
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


# samp_int (sec)
set samp_int 0.01
# link_cap (Mbps)
set link_cap 10Mb
set link_bneck 1Mb
# link_delay (ms)
set link_delay 1ms
set queue_type DropTail
# set link_delay 5ms
# tcp_window (pkts)
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


set trace_dir /Users/oljideje/workspace/repos/ns-install-osx/dctcp-example/smptcp

#
# setup trace files
#
set f [open "|gzip > $trace_dir/out.tr.gz" w]
$ns trace-all $f

set mtrace [open "|gzip > $trace_dir/trace.tr.gz" w]

# Queue options
Queue set limit_ $q_size

#
# mptcp sender
#
set MPTCP_Core_Nodes 6
set MPTCP_subflows 2
# create MPTCP sender and receiver nodes 
for {set i 0} {$i < $MPTCP_Core_Nodes} {incr i} {
    set n($i) [$ns node]
    
    for {set j 0} {$j < $MPTCP_subflows} {incr j} {
      set n_($i-$j) [$ns node]
      $ns multihome-add-interface $n($i) $n_($i-$j)

    }   
}



# Create switche nodes 
set NSwitches 6
for {set i 0} {$i < $NSwitches} {incr i} {
    set sw($i) [$ns node]  
}

# connect switches

for {set i 0} {$i < [expr $NSwitches - 3]} {incr i} {
  $ns duplex-link $sw($i) $sw([expr $i+3]) $link_cap $link_delay $queue_type
  # connect competing node sender to switch
  # $ns duplex-link $c($i) $sw($i) $link_cap $link_delay $queue_type
  # connect competing node receiver to switch
  # $ns duplex-link $c([expr $i+2]) $sw([expr $i+2]) $link_cap $link_delay $queue_type

}

# connect nodes to switches

for {set i 0} {$i < [expr $MPTCP_Core_Nodes-3] } {incr i} {

    for {set j 0} {$j <[expr $MPTCP_subflows-1]} {incr j} {
      if {$i == 0} {
         $ns duplex-link $n_($i-$j) $sw($j) $link_cap $link_delay $queue_type
         $ns duplex-link $n_($i-[expr $j+1]) $sw([expr $i+2]) $link_cap $link_delay $queue_type

         $ns duplex-link $n_([expr $i+3]-$j) $sw([expr $j+3]) $link_cap $link_delay $queue_type
         $ns duplex-link $n_([expr $i+3]-[expr $j+1]) $sw([expr $i+5]) $link_cap $link_delay $queue_type

      } elseif {$i == 1} {
         $ns duplex-link $n_($i-$j) $sw($j) $link_cap $link_delay $queue_type
         $ns duplex-link $n_($i-[expr $j+1]) $sw($i) $link_cap $link_delay $queue_type

         $ns duplex-link $n_([expr $i+3]-$j) $sw([expr $j+3]) $link_cap $link_delay $queue_type
         $ns duplex-link $n_([expr $i+3]-[expr $j+1]) $sw([expr $i+3]) $link_cap $link_delay $queue_type

        

      } elseif {$i == 2} {
        $ns duplex-link $n_($i-$j) $sw([expr $j+1]) $link_cap $link_delay $queue_type
         $ns duplex-link $n_($i-[expr $j+1]) $sw($i) $link_cap $link_delay $queue_type

         $ns duplex-link $n_([expr $i+3]-$j) $sw([expr $j+4]) $link_cap $link_delay $queue_type
         $ns duplex-link $n_([expr $i+3]-[expr $j+1]) $sw([expr $i+3]) $link_cap $link_delay $queue_type

      }  
    }   
}




# create MPTCP senders and receivers
# set tracer_ [new Trace/Var]
# $tracer_ attach [open cwndtrace.tr w]


set k 0
for {set i 0} {$i < $MPTCP_Core_Nodes} {incr i} {
  set mptcp($i) [new Agent/MPTCP]
  
  
  # set tcp($i) [new Agent/TCP/FullTcp/Sack/Multipath]

  for {set j 0} {$j < $MPTCP_subflows} {incr j} {
    set tcp_($i-$j) [new Agent/TCP/FullTcp/Sack/Multipath]
    $ns attach-agent $n_($i-$j) $tcp_($i-$j) 
    $mptcp($i) attach-tcp $tcp_($i-$j)
    
    # $tcp_($i-$j) trace cwnd_ $tracer_
    # puts "$tcp_($i-$j)"
    if {$i < 3 } {
      set tcp($k) $tcp_($i-$j)
      incr k
    } 

    # $tcp_($i-$j) attach $mtrace; # attach to TCP Agent
    # $tcp_($i-$j) tracevar cwnd_
    
    # $tcp_($i-$j) tracevar dctcp_alpha_

    } 

  $ns multihome-attach-agent $n($i) $mptcp($i)
  
  if {$i < 3} {
    set ftp($i) [new Application/FTP]
    $ftp($i) attach-agent $mptcp($i)
  } elseif { $i > 2} {
    $ns multihome-connect $mptcp([expr $i-3]) $mptcp($i)
    $mptcp($i) listen
  }
   
}



proc myTrace {file} {
  global ns N samp_int tcp mtrace MPTCP_Core_Nodes MPTCP_subflows
    

  set now [$ns now]



  for {set i 0} {$i < [expr $MPTCP_Core_Nodes-3]} {incr i} {
  
      # puts "$now [$tcp_($i-$j) set cwnd_]"

      if {$i == 0} {
        puts -nonewline $file "$now [$tcp($i) set cwnd_]"
        puts -nonewline $file " [$tcp([expr $i + 1]) set cwnd_]"

      
      } elseif {$i == 1} {
        puts -nonewline $file " [$tcp([expr $i + 1]) set cwnd_]"
        puts -nonewline $file " [$tcp([expr $i + 2]) set cwnd_]"
        
        # puts "Inside myTrace [$tcp1 set cwnd_] "
        
      } else {
        puts -nonewline $file " [$tcp([expr $i + 2]) set cwnd_]"
        puts $file " [$tcp([expr $i + 3]) set cwnd_]"
       
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
for {set i 0} {$i < [expr $MPTCP_Core_Nodes-3]} {incr i} {
  $ns at 0.0 "$ftp($i) start"

  }       
$ns at 30.0 "finish"
$ns run
