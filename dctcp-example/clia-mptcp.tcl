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

set trace_dir /Users/oljideje/workspace/repos/ns-install-osx/dctcp-example/smptcp

#
# setup trace files
#
set f [open "|gzip > $trace_dir/out.tr.gz" w]
$ns trace-all $f

set mtrace [open "|gzip > $trace_dir/trace.tr.gz" w]
# Queue options
Queue set limit_ $q_size


# HOST options
Agent/TCP set window_ $tcp_window
Agent/TCP set windowInit_ 2
Agent/TCP set packetSize_ $pktSize
Agent/TCP/FullTcp set segsize_ $pktSize

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

for {set i 0} {$i < $NTCP} {incr i} {
    set c($i) [$ns node]
    if {$i <= 1} {
      set ctcp($i) [new Agent/TCP/FullTcp/Sack]
      $ctcp($i) set window_ $tcp_window 
      $ns attach-agent $c($i) $ctcp($i)
      set ftpc($i) [new Application/FTP]
      $ftpc($i) attach-agent $ctcp($i)
      # set ctcp0 $ctcp($i)

    } elseif {$i <= 3} {
      set ctcp($i) [new Agent/TCP/FullTcp/Sack]
      $ns attach-agent $c($i) $ctcp($i)
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
  # connect competing node sender to switch
  $ns duplex-link $c($i) $sw($i) $link_cap $link_delay $queue_type
  # connect competing node receiver to switch
  $ns duplex-link $c([expr $i+2]) $sw([expr $i+2]) $link_cap $link_delay $queue_type

}

# connect nodes to switches

for {set i 0} {$i < $MPTCP_Core_Nodes} {incr i} {

    for {set j 0} {$j <$MPTCP_subflows} {incr j} {
      if {$i == 0} {
         $ns duplex-link $n_($i-$j) $sw($j) $link_cap $link_delay $queue_type
      } elseif {$i == 1} {
        $ns duplex-link $n_($i-$j) $sw([expr $j+2]) $link_cap $link_delay $queue_type

      } 
    }   
}




# create MPTCP senders and receivers
# set tracer_ [new Trace/Var]
# $tracer_ attach [open cwndtrace.tr w]
set ftp [new Application/FTP]


for {set i 0} {$i < $MPTCP_Core_Nodes} {incr i} {
  set mptcp($i) [new Agent/MPTCP]
  # set tcp($i) [new Agent/TCP/FullTcp/Sack/Multipath]

  for {set j 0} {$j < $MPTCP_subflows} {incr j} {
    set tcp_($i-$j) [new Agent/TCP/FullTcp/Sack/Multipath]
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
  global ns N samp_int tcp mtrace MPTCP_Core_Nodes MPTCP_subflows ctcp
    

  set now [$ns now]

  for {set i 0} {$i < [expr $MPTCP_Core_Nodes-1]} {incr i} {

    for {set j 0} {$j < $MPTCP_subflows} {incr j} {
      
      
      # puts "$now [$tcp_($i-$j) set cwnd_]"

      if {$j == 0} {
        puts -nonewline $file "$now [$tcp($j) set cwnd_]"
        puts -nonewline $file " [$tcp([expr $j + 1]) set cwnd_]"
        puts -nonewline $file " [$ctcp($j) set cwnd_]"
        
      } else {
        puts $file " [$ctcp($j) set cwnd_]"
        # puts "Inside myTrace [$tcp1 set cwnd_] "
        
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
$ns at 5.0 "$ftpc(0) start" 
$ns at 10.0 "$ftpc(0) stop" 
$ns at 10.0 "$ftpc(1) start" 
# $ns at 4.5 "$ftp stop"       
$ns at 15.0 "finish"
$ns run
