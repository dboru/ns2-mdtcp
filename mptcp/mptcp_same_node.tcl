#
#
# sample script for mptcp implementation on ns-2
#
#      Yoshifumi Nishida <nishida@sfc.wide.ad.jp>
#
#
set ns [new Simulator]
 # setup simulator
 remove-all-packet-headers;     # removes all packet headers - saves memory
 add-packet-header IP TCP;      # adds TCP/IP headers

set tracefile [open out.tr w]
$ns trace-all $tracefile
set nf [open out.nam w]
$ns namtrace-all $nf
proc finish {} \
{
	global ns tracefile nf
	$ns flush-trace
	close $nf
	close $tracefile
	#exec nam out.nam & 
	exit 0
	
}


# specify to print mptcp option information
Trace set show_tcphdr_ 2

set n0 [$ns node]
set n0_0 [$ns node]
set n0_1 [$ns node]
$n0 color red
$n0_0 color red
$n0_1 color red

$ns multihome-add-interface $n0 $n0_0
$ns multihome-add-interface $n0 $n0_1
# mptcp receiver

set n1 [$ns node]
set n1_0 [$ns node]
set n1_1 [$ns node]
$n1 color blue
$n1_0 color blue
$n1_1 color blue
$ns multihome-add-interface $n1 $n1_0
$ns multihome-add-interface $n1 $n1_1
set r1 [$ns node]
set r2 [$ns node]
# connect nodes
$ns duplex-link $n0_0 $r1 1Mb 5ms DropTail
$ns duplex-link $n0_1 $r1 1Mb 5ms DropTail
$ns duplex-link $r1 $r2 1Kb 5ms   DropTail
$ns duplex-link $n1_0 $r2 1Mb 5ms DropTail
$ns duplex-link $n1_1 $r2 1Mb 5ms DropTail
#   sub-flow 0 sender
set tcp0 [new Agent/TCP/FullTcp/Sack/Multipath]
$tcp0 set window_ 100
#  attach sub-flow 0 to interface n0_0 
$ns attach-agent $n0_0 $tcp0
#  sub-flow 1 sender
set tcp1 [new Agent/TCP/FullTcp/Sack/Multipath]
$tcp1 set window_ 100
#Attach sub-flow 1 sender to interface n0_1
$ns attach-agent $n0_1 $tcp1
#core tcp sender 
set mptcp0 [new Agent/MPTCP]
$mptcp0 attach-tcp $tcp0
$mptcp0 attach-tcp $tcp1
$ns multihome-attach-agent $n0 $mptcp0
# create and attach application to mptcp core
set cbr [new Application/FTP]
$cbr attach-agent $mptcp0

# create mptcp receiver
#  create multi-path tcp core sink
set mptcpsink0 [new Agent/MPTCP]
set sink0 [new Agent/TCP/FullTcp/Sack/Multipath]
$ns attach-agent $n1_0 $sink0 
#  create sub-flow 1 receiver
set sink1 [new Agent/TCP/FullTcp/Sack/Multipath]
#  attach sub-flow 1 receiver to interface n1_1
$ns attach-agent $n1_1 $sink1
#  attach sub-flow receivers to core receiver 
$mptcpsink0 attach-tcp $sink0
$mptcpsink0 attach-tcp $sink1
#  attach core multi-path receiver to receiver node
$ns multihome-attach-agent $n1 $mptcpsink0 
$ns multihome-connect $mptcp0 $mptcpsink0
$ns connect $tcp0 $sink0
$ns connect $tcp1 $sink1
$mptcpsink0 listen
$ns at 0.0  "$cbr start"
$ns at 2.0  "finish"
$ns run
