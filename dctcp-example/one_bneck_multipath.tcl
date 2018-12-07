#
#
# multipath with dctcp fairness test
#
#      Dejene B. Oljira <oljideje@kau.se>
#
#

# The ns-2 TCPs require setting window sizes and buffer sizes in number of packets.
set ns [new Simulator]
remove-all-packet-headers
add-packet-header IP TCP
#
# specify to print mptcp option information
#
set mpdctcp false
set cdctcp  false
set queue_type DropTail
set ctype tcp
set mptype tcp
set qtype droptail
set qfile "qmp"
if { $argc == 3 } {
    set i 1
    foreach arg $argv {
      if { $i==1 } {
        set under_score "_"
        if {[string compare $arg "dctcp"] == 0} {
          set mpdctcp true
          set qfile $qfile$arg$under_score
          set mptype mpdctcp
          
        } else {
          set qfile $qfile$arg$under_score
        }
      } elseif { $i==2 } {

        if {[string compare $arg "dctcp"] == 0} {
          set cdctcp true
          set qfile $qfile$arg
          set ctype dctcp
        } else {
          set qfile $qfile$arg
        }

      } elseif { $i==3 } {

        if {[string compare $arg "red"] == 0} {
          set queue_type RED
          set qtype red
          # set qfile $qfile$arg
        } 

      }
        
        incr i
    }
} else {
    puts "usage: ns one_bneck_multipath.tcl dctcp/tcp dctcp/tcp red/droptail (3 args required)"
    exit
}

# if {$argc > 0} {puts "The other arguments are: $argv" }

# puts "You have these environment variables set:"
# foreach index [array]
# foreach index [array names env] {
#     puts "$index: $env($index)"
# }

Trace set show_tcphdr_ 2

##In case TCP , BWxRTT
# set queueSize [expr int (ceil (($mean_link_delay * 2.0 * $link_rate * 1000000000.0/8.0) / ($pktSize+40.0)))]
#set tcpwin_ [expr 4 * int (ceil (($mean_link_delay * 2.0 * $link_rate * 1000000000.0/8.0) / ($pktSize+40.0)))]
#Agent/TCP set window_ $tcpwin_
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
set link_bneck 10Mb
# link_delay (ms)
set link_delay 5ms
# set queue_type DropTail
# set link_delay 5ms
# tcp_window (pkts)
set tcp_window 100
# run_time (sec)
# set run_time 10.0
# pktSize (bytes)
set pktSize 1460
# max buffer size 
set q_size 30

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
# Default queue limit_ is 50 pkts


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
# RED min threshold
Queue/RED set drop_prio_ $drop_prio_
Queue/RED set deque_prio_ $deque_prio_


# DCTCP setting
if {$mpdctcp == true} {
  Queue/RED set q_weight_ 1.0
  Queue/RED set mark_p_ 1.0
  Queue/RED set thresh_ $DCTCP_K
  Queue/RED set maxthresh_ $DCTCP_K
  # Agent/TCP set dctcp_ true
  Agent/TCP set ecnhat_g_ $DCTCP_g;
  # puts "setting mpdctcp $mpdctcp $cdctcp $qtype $queue_type"

  
} else {
  # TCP-RED config
  Queue/RED set q_weight_ 9.0
  Queue/RED set mark_p_ 0.1
  # min threshold
  Queue/RED set thresh_ $q_size
  # max threshold
  Queue/RED set maxthresh_ $q_size
  # Agent/TCP set dctcp_ false
  # puts "setting mpdctcp $mpdctcp $cdctcp $qtype $queue_type"
 
}


DelayLink set avoidReordering_ true
# set only one of them not both
Agent/MPTCP set lia_ 1
Agent/MPTCP set lia_dctcp_alpha_ 0

Agent/TCP set window_ $tcp_window
Agent/TCP set windowInit_ 2
Agent/TCP set packetSize_ $pktSize
Agent/TCP/FullTcp set segsize_ $pktSize
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

set trace_dir ./smptcp
Queue set limit_ 60
#
# setup trace files
#

set f [open "|gzip > $trace_dir/out.tr.gz" w]
$ns trace-all $f
set qfile $qfile.tr.gz
set mtrace [open "|gzip > $trace_dir/trace.tr.gz" w]
set qlen [open "|gzip > $trace_dir/$qfile" w]

set tcpfile [open "|gzip > $trace_dir/tcp1.tr.gz" w]
Agent/TCP set trace_all_oneline_ true

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

set NTCP 2
# 6->7 
for {set i 0} {$i < $NTCP} {incr i} {
    set c($i) [$ns node]
   
    if {$i < 1} {
      set ctcp($i) [new Agent/TCP/FullTcp/Sack]
      $ctcp($i) set dctcp_ $cdctcp
      puts "$cdctcp"
      $ns attach-agent $c($i) $ctcp($i)
      set ftpc($i) [new Application/FTP]
      $ftpc($i) attach-agent $ctcp($i)
      $ctcp($i) attach-trace $tcpfile
      $ctcp($i) trace cwnd_
      $ctcp($i) trace rtt_
      

    } else {
      set ctcp($i) [new Agent/TCP/FullTcp/Sack]
      $ns attach-agent $c($i) $ctcp($i)
      $ctcp($i) set dctcp_ $cdctcp
      puts "$cdctcp"
      $ns connect $ctcp([expr $i-1]) $ctcp($i)
      $ctcp($i) listen
    }        
}


# Create switche nodes 

set NSwitches 2
for {set i 0} {$i < $NSwitches} {incr i} {
    set sw($i) [$ns node]  
}
# set NSwitches 2
# connect switches

for {set i 0} {$i < [expr $NSwitches - 1]} {incr i} {
  $ns duplex-link $sw($i) $sw([expr $i+1]) $link_bneck $link_delay $queue_type
  $ns queue-limit $sw($i) $sw([expr $i+1]) $q_size


  # set redq [[$ns link $sw($i) $sw([expr $i+1])] queue]
  # $redq attach $qlen
  # $redq trace curq_
  # $redq trace ave_
  # since the max_thresh and min_thresh are equal, curq and aveg are the same for RED

# queue trace format
# a time avg_q_size
# Q time crnt_q_size



  
  # connect competing node sender to switch
  $ns duplex-link $c($i) $sw($i) $link_cap $link_delay DropTail
  $ns duplex-link $c([expr $i+1]) $sw([expr $i+1]) $link_cap $link_delay DropTail
  

}

# connect nodes to switches

for {set i 0} {$i < $MPTCP_Core_Nodes} {incr i} {

    for {set j 0} {$j <$MPTCP_subflows} {incr j} {
      if {$i== 0 && $j == 0} {
         $ns duplex-link $n_($i-$j) $sw($i) $link_cap $link_delay DropTail

      } else {
        $ns duplex-link $n_($i-$j) $sw($i) $link_cap $link_delay DropTail
      }
      
      
    }   
}

puts "MP: $mpdctcp Cflow: $cdctcp Qtype: $qtype Qtype: $queue_type"


# create MPTCP senders and receivers
# set tracer_ [new Trace/Var]
# $tracer_ attach [open cwndtrace.tr w]
set ftp [new Application/FTP]
for {set i 0} {$i < $MPTCP_Core_Nodes} {incr i} {
  set mptcp($i) [new Agent/MPTCP]
  for {set j 0} {$j < $MPTCP_subflows} {incr j} {
    set tcp_($i-$j) [new Agent/TCP/FullTcp/Sack/Multipath]
    $tcp_($i-$j) set dctcp_ $mpdctcp
    $ns attach-agent $n_($i-$j) $tcp_($i-$j) 
    $mptcp($i) attach-tcp $tcp_($i-$j)
    
    if {$i == 0  && $j <= 1} {
      set tcp($j) $tcp_($i-$j)
      $tcp($j) attach-trace $tcpfile
      $tcp($j) trace cwnd_
      $tcp($j) trace rtt_
    } 

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
      if {$j == 0} {
        puts -nonewline $file "$now [$tcp($j) set cwnd_]"
        puts -nonewline $file " [$tcp([expr $j + 1]) set cwnd_]"
        puts -nonewline $file " [$tcp($j) set dctcp_alpha_]"
        puts -nonewline $file " [$tcp([expr $j + 1]) set dctcp_alpha_]"
        puts -nonewline $file " [$ctcp($j) set cwnd_]"
        # puts -nonewline $file "$now [$tcp($j) set nrexmitpack_]"
        # puts  -nonewline $file " [$tcp([expr $j + 1]) set dctcp_alpha_]"
        puts  $file " [$ctcp($j) set dctcp_alpha_]"
        # puts $file " [$ctcp($j) set cwnd_]" 
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
  
  # exec "./trace_process.sh "
  
  exit   
}


$ns at $samp_int "myTrace $mtrace"
# $ns at $snd_intvl "next_send"
$ns at 5.0 "$ftp start"
 
$ns at 0.0 "$ftpc(0) start"        
$ns at 60 "finish"
$ns run
