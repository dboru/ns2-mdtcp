# one-flow.tcl
#
# Demonstrates setting up a simple dumbell network and sending 
# one-way long-lived TCP traffic 
#
# Dejene B. Oljira, July 2017
#

    
    set ns_ [new Simulator];       # instantiate the simulator
    set end 20.0
    set trace_dir /Users/oljideje/workspace/repos/ns-install-osx/dctcp-example/smptcp
    # setup simulator
    remove-all-packet-headers;     # removes all packet headers - saves memory
    add-packet-header IP TCP;      # adds TCP/IP headers

    # Trace set show_tcphdr_ 1


    #-------------------------------------------------------------------------
    # SETUP NETWORK
    #-------------------------------------------------------------------------
    set f [open "|gzip > $trace_dir/out.tr.gz" w]
    $ns_ trace-all $f
    # create nodes
    for {set i 0} {$i < 2} {incr i} {
	set n($i) [$ns_ node];         # end nodes 0 (n0) 1(n2) 2(r0) 3(n1) 4(n3) 5(r1) 
    set n([expr $i+2]) [$ns_ node];         # end nodes
	set r($i) [$ns_ node];         # router nodes
    }
    # sender to recevier: 0->3 and 1->4
    # create links
    $ns_ duplex-link $r(0) $r(1) 10Mbps 1ms DropTail;  # between routers
    $ns_ queue-limit $r(0) $r(1) 30

    # links between end nodes and routers (order of nodes doesn't matter)
    $ns_ duplex-link $n(0) $r(0) 10Mbps 1ms DropTail
    $ns_ duplex-link $n(1) $r(1) 10Mbps 1ms DropTail

    # competing flow 
    $ns_ duplex-link $n(2) $r(0) 10Mbps 1ms DropTail
    $ns_ duplex-link $n(3) $r(1) 10Mbps 1ms DropTail


    #-------------------------------------------------------------------------
    # SETUP END NODES
    #-------------------------------------------------------------------------
    set tcpsrc [new Agent/TCP/Reno]; # create TCP sending Agent
    $tcpsrc set fid_ 1
    $tcpsrc set packetSize_ 1460;    # all packets have same size
    $tcpsrc set window_ 100;          # maximum congestion window size (pckts)

    set tcpsrc1 [new Agent/TCP/Reno]; # create TCP sending Agent
    $tcpsrc1 set fid_ 2
    $tcpsrc1 set packetSize_ 1460;    # all packets have same size
    $tcpsrc1 set window_ 100;          # maximum congestion window size (pckts)


    $ns_ attach-agent $n(0) $tcpsrc; # all Agents must be attached to a node

    $ns_ attach-agent $n(2) $tcpsrc1; # all Agents must be attached to a node

    set tcpsink [new Agent/TCPSink]; # TCP receiver
    $ns_ attach-agent $n(1) $tcpsink

    set tcpsink1 [new Agent/TCPSink]; # TCP receiver
    $ns_ attach-agent $n(3) $tcpsink1

    #-------------------------------------------------------------------------
    # SETUP TRACING
    #-------------------------------------------------------------------------

    # tracing TCP variables
    set tracevar_chan_ [open "|gzip > $trace_dir/trace.tr.gz" w];  # trace file
    # $tcpsrc attach $tracevar_chan_;            # attach to TCP Agent
    # $tcpsrc tracevar cwnd_;                    # trace cwnd
    # $tcpsrc1 attach $tracevar_chan_;            # attach to TCP Agent
    # $tcpsrc1 tracevar cwnd_;
    # can trace anything in tcp.h defined with Traced*
    # (t_seqno_, ssthresh_, t_rtt_, dupacks_, ...)

    # tracing links
    #    Trace set show_tcphdr_ 1;             # displays extra TCP header info

    # trace all packet events between src and 1st router
    set trq_src0_ [open "|gzip > $trace_dir/TCP-src0.trq.gz" w]
    $ns_ trace-queue $n(0) $r(0) $trq_src0_
    $ns_ trace-queue $r(0) $n(0) $trq_src0_;   # order matters here

    # trace all packet events between dst and 2nd router
    set trq_dst1_ [open "|gzip > $trace_dir/TCP-dst1.trq.gz" w]
    $ns_ trace-queue $n(1) $r(1) $trq_dst1_
    $ns_ trace-queue $r(1) $n(1) $trq_dst1_

    # trace all packet events between the two routers
    set trq_01_ [open "|gzip > $trace_dir/TCP-q01.trq.gz" w]
    $ns_ trace-queue $r(0) $r(1) $trq_01_
    $ns_ trace-queue $r(1) $r(0) $trq_01_

    #-------------------------------------------------------------------------
    # MAKE THE CONNECTION
    #-------------------------------------------------------------------------
    $ns_ connect $tcpsrc $tcpsink
    $tcpsink listen

    $ns_ connect $tcpsrc1 $tcpsink1
    $tcpsink1 listen

    #-------------------------------------------------------------------------
    # SETUP TRAFFIC
    #-------------------------------------------------------------------------

    # FTP application
    set ftp [new Application/FTP]
    $ftp attach-agent $tcpsrc
    set ftp1 [new Application/FTP]
    $ftp1 attach-agent $tcpsrc1
                              # GO!

proc myTrace {file} {
  global ns_ tcpsrc tcpsrc1 
  
  set now [$ns_ now]

  
        puts -nonewline $file "$now [$tcpsrc set cwnd_]"
        puts $file " [$tcpsrc1 set cwnd_]"
        

        # puts -nonewline $file " [$tcp($j) set rtt_]"
        # puts -nonewline $file " [$tcp([expr $j + 1]) set rtt_]"
        # puts -nonewline $file " [$tcp($j) set rttvar_]"
        # puts -nonewline $file " [$tcp([expr $j + 1]) set rttvar_]"
        # puts -nonewline $file " [$tcp($j) set ssthresh_]"
        # puts $file " [$tcp([expr $j + 1]) set ssthresh_]"

 
 $ns_ at [expr $now+0.01] "myTrace $file"


}
proc finish {} {

    # insert post-processing code here

    #-------------------------------------------------------------------------
    # EXAMPLES
    #-------------------------------------------------------------------------

    # printing output:
    # puts "Finished!"
    # puts stderr "Finished!"
    # puts [format "%f" [expr ($timeouts / $segs)]]

    # running shell commands:
    # exec gunzip -c TCP-q01.trq.gz | awk {{if ($1=="+" && $5=="tcp" && $6>40) print $6}}
    # exec zcat TCP-q01.trq.gz | awk {{if ($1=="+" && $5=="tcp" && $6>40) print $6}}
    # This works in command line but not in tcl script 
    # exec gzcat TCP-q01.trq.gz | awk '{print $1 "  " $4}'
    exit 0;
}

#-------------------------------------------------------------------------
    # MAKE SCHEDULE
    #-------------------------------------------------------------------------

    # schedule this FTP flow
    $ns_ at 0.0 "$ftp start";         # send packets forever
    $ns_ at 0.0 "$ftp1 start";
    $ns_ at $end "$ftp stop"
    $ns_ at $end "$ftp1 stop"
    $ns_ at 0.0 "myTrace $tracevar_chan_"

#  The above could be done without an FTP Application with this line:
#    $ns_ at 0.0 "$tcpsrc send -1";    # send packets forever

    $ns_ at $end "finish";             # end of simulation

    # # output progress
    # for {set i 0} {$i<$end} {incr i} {
    # $ns_ at $i "puts stderr \"time $i\""
    # }

    $ns_ run;

